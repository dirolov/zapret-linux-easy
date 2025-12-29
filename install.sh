#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@" || exec doas "$0" "$@"
    exit 1
fi

rm -f /usr/lib/systemd/system/zapret.service > /dev/null 2>&1
rm -rf /opt/zapret > /dev/null 2>&1
killall nfqws > /dev/null 2>&1

mkdir -p /opt/zapret
cp -r ./files/* /opt/zapret/

chmod +x /opt/zapret/system/starter.sh
chmod +x /opt/zapret/system/stopper.sh
arch=$(uname -m)
case "$arch" in
    x86_64)
        bin_dir="x86_64"
        ;;
    i386|i686)
        bin_dir="x86"
        ;;
    armv7l|armv6l)
        bin_dir="arm"
        ;;
    aarch64)
        bin_dir="arm64"
        ;;
    riscv64)
        bin_dir="riscv64"
        ;;
    *)
        echo "Unknown architecture: $arch"
        exit 1
        ;;
esac

cp "./bins/$bin_dir/nfqws" /opt/zapret/system/
chmod +x /opt/zapret/system/nfqws

echo "Select firewall type:"
echo "1. iptables"
echo "2. nftables"
read -rp "Введите номер (1 или 2): " choice
case $choice in
    1)
        echo "iptables" > /opt/zapret/system/FWTYPE
        echo "Firewall type set: iptables"
        ;;
    2)
        echo "nftables" > /opt/zapret/system/FWTYPE
        echo "Firewall type set: nftables"
        ;;
    *)
        echo "Error: Invalid selection. Please choose 1 or 2."
        exit 1
        ;;
esac

available_ifaces=$(ls /sys/class/net 2>/dev/null | tr '\n' ' ')

echo ""
echo "Available interfaces: $available_ifaces"
echo "Enter WAN interface(s) space separeted (e.g. eth0). Leave empty to apply to ALL interfaces (default):"
read -p "> " wan_iface
echo "$wan_iface" > /opt/zapret/system/IFACE_WAN

echo "Enter LAN interface(s) space separeted (e.g. br-lan). Leave empty to apply to ALL interfaces (default):"
read -p "> " lan_iface
echo "$lan_iface" > /opt/zapret/system/IFACE_LAN

if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd ]; then
bash "$PWD"/files/scripts/systemd.sh

elif command -v openrc-run >/dev/null 2>&1 && [ -d /run/openrc ]; then
bash "$PWD"/files/scripts/openrc.sh

elif command -v runit >/dev/null 2>&1 && [ -d /run/runit ]; then
bash "$PWD"/files/scripts/runit-artix.sh

elif command -v runit >/dev/null 2>&1 && [ -d /var/service ]; then
bash "$PWD"/files/scripts/runit.sh

elif command -v dinitctl >/dev/null 2>&1 && [ -d /etc/dinit.d ]; then
bash "$PWD"/files/scripts/dinit.sh
    
else
    echo "Не удалось определить систему инициализации (systemd, OpenRC или runit не найдены)."
    exit 1
fi
