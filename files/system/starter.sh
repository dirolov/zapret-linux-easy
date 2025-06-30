#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

if pidof "nfqws" > /dev/null; then
    echo "nfqws is already running."
    exit 0
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

TCP_PORTS=$(echo "$ARGS" | tr -s ' ' '\n' | grep '^--filter-tcp=' | sed 's/--filter-tcp=//' | paste -sd, | sed 's/-/:/g')
UDP_PORTS=$(echo "$ARGS" | tr -s ' ' '\n' | grep '^--filter-udp=' | sed 's/--filter-udp=//' | paste -sd, | sed 's/-/:/g')

echo "Configuring iptables for TCP ports: $TCP_PORTS"
echo "Configuring iptables for UDP ports: $UDP_PORTS"

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

/opt/zapret/system/nfqws --qnum=200 --uid=0:0 $ARGS &
