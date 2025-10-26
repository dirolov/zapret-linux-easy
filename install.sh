#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
    exit 1
fi

rm /usr/lib/systemd/system/zapret.service > /dev/null 2>&1
rm -rf /opt/zapret > /dev/null 2>&1
killall nfqws > /dev/null 2>&1

mkdir -p /opt/zapret
cp -r ./files/* /opt/zapret/

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
    *)
        echo "Неизвестная архитектура: $arch"
        exit 1
        ;;
esac

cp "./bins/$bin_dir/nfqws" /opt/zapret/system/
chmod +x /opt/zapret/system/nfqws

echo "Выберите тип firewall:"
echo "1. iptables"
echo "2. nftables"
read -p "Введите номер (1 или 2): " choice
case $choice in
    1)
        echo "iptables" > /opt/zapret/system/FWTYPE
        echo "Тип firewall установлен: iptables"
        ;;
    2)
        echo "nftables" > /opt/zapret/system/FWTYPE
        echo "Тип firewall установлен: nftables"
        ;;
    *)
        echo "Ошибка: Неверный выбор. Пожалуйста, выберите 1 или 2."
        exit 1
        ;;
esac

if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd ]; then

elif command -v openrc-run >/dev/null 2>&1 || [ -d /run/openrc ]; then
    
else
    echo "Не удалось определить систему инициализации (systemd или OpenRC не найдены)."
    exit 1
fi
