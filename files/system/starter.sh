#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

if pidof "nfqws" > /dev/null; then
    echo "nfqws is already running."
    exit 0
fi

if [ -f /opt/zapret/system/FWTYPE ]; then
    content=$(cat /opt/zapret/system/FWTYPE)
    if [ "$content" = "iptables" ]; then
        FWTYPE=iptables
    elif [ "$content" = "nftables" ]; then
        FWTYPE=nftables
    else
        echo "Ошибка: Неверное значение в файле FWTYPE."
        exit 1
    fi
    echo "FWTYPE=$FWTYPE"
else
    echo "Ошибка: Файл /opt/zapret/system/FWTYPE не найден."
    exit 1
fi

ARGS=""
while IFS= read -r line; do
    line="${line//\{hosts\}//opt/zapret/autohosts.txt}"
    line="${line//\{youtube\}//opt/zapret/youtube.txt}"
    line="${line//\{ignore\}//opt/zapret/ignore.txt}"
    line="${line//\{quicgoogle\}//opt/zapret/system/quic_initial_www_google_com.bin}"
    line="${line//\{tlsgoogle\}//opt/zapret/system/tls_clienthello_www_google_com.bin}"
    line="$(echo "$line" | sed -E 's/--wf-(tcp|udp)=[^ ]+//g')"
    line="$(echo "$line" | sed -E 's/  +/ /g' | sed -E 's/^ //;s/ $//')"
    ARGS+=" $line"
done < "/opt/zapret/config.txt"

sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1

if [ "$FWTYPE" = "iptables" ]; then
    TCP_PORTS=$(echo "$ARGS" | tr -s ' ' '\n' | grep '^--filter-tcp=' | sed 's/--filter-tcp=//' | paste -sd, | sed 's/-/:/g')
    UDP_PORTS=$(echo "$ARGS" | tr -s ' ' '\n' | grep '^--filter-udp=' | sed 's/--filter-udp=//' | paste -sd, | sed 's/-/:/g')
elif [ "$FWTYPE" = "nftables" ]; then
    TCP_PORTS=$(echo "$ARGS" | tr -s ' ' '\n' | grep '^--filter-tcp=' | sed 's/--filter-tcp=//' | paste -sd, | sed 's/:/-/g')
    UDP_PORTS=$(echo "$ARGS" | tr -s ' ' '\n' | grep '^--filter-udp=' | sed 's/--filter-udp=//' | paste -sd, | sed 's/:/-/g')
fi

echo "Configuring iptables for TCP ports: $TCP_PORTS"
echo "Configuring iptables for UDP ports: $UDP_PORTS"

if [ "$FWTYPE" = "iptables" ]; then
    iptables -t mangle -F PREROUTING
    iptables -t mangle -F POSTROUTING
elif [ "$FWTYPE" = "nftables" ]; then
    nft add table inet zapret
    nft flush table inet zapret
    nft add chain inet zapret prerouting { type filter hook prerouting priority mangle \; }
    nft add chain inet zapret postrouting { type filter hook postrouting priority mangle \; }
fi

if [ "$FWTYPE" = "iptables" ]; then
    if [ -n "$TCP_PORTS" ]; then
    iptables -t mangle -I POSTROUTING -p tcp -m multiport --dports "$TCP_PORTS" \
        -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:12 \
        -j NFQUEUE --queue-num 200 --queue-bypass
    iptables -t mangle -I PREROUTING -p tcp -m multiport --sports "$TCP_PORTS" \
        -m connbytes --connbytes-dir=reply --connbytes-mode=packets --connbytes 1:6 \
        -j NFQUEUE --queue-num 200 --queue-bypass
fi

if [ -n "$UDP_PORTS" ]; then
    iptables -t mangle -I POSTROUTING -p udp -m multiport --dports "$UDP_PORTS" \
        -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:12 \
        -j NFQUEUE --queue-num 200 --queue-bypass
    iptables -t mangle -I PREROUTING -p udp -m multiport --sports "$UDP_PORTS" \
        -m connbytes --connbytes-dir=reply --connbytes-mode=packets --connbytes 1:6 \
        -j NFQUEUE --queue-num 200 --queue-bypass
fi
elif [ "$FWTYPE" = "nftables" ]; then
    if [ -n "$TCP_PORTS" ]; then
    nft add rule inet zapret postrouting tcp dport { $TCP_PORTS } ct original packets 1-12 queue num 200 bypass
    nft add rule inet zapret prerouting tcp sport { $TCP_PORTS } ct reply packets 1-6 queue num 200 bypass
fi

if [ -n "$UDP_PORTS" ]; then
    nft add rule inet zapret postrouting udp dport { $UDP_PORTS } ct original packets 1-12 queue num 200 bypass
    nft add rule inet zapret prerouting udp sport { $UDP_PORTS } ct reply packets 1-6 queue num 200 bypass
fi
fi

/opt/zapret/system/nfqws --qnum=200 --uid=0:0 $ARGS &
