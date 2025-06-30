#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
    exit 1
fi

steamos-readonly disable
pacman-key --init
pacman-key --populate archlinux
pacman-key --populate holo
pacman -Syu --noconfirm ipset iptables

rm /usr/lib/systemd/system/zapret.service > /dev/null 2>&1
rm -rf /opt/zapret > /dev/null 2>&1
killall nfqws > /dev/null 2>&1

mkdir -p /opt/zapret
cp -r ./files/* /opt/zapret/
cp "./bins/x86_64/nfqws" /opt/zapret/system/
cp /opt/zapret/system/zapret.service /usr/lib/systemd/system/zapret.service

cat <<EOF > /home/deck/Desktop/after_update.sh
#!/bin/sh
if [ "\$(id -u)" -ne 0 ]; then
    exec sudo "\$0" "\$@"
    exit 1
fi

steamos-readonly disable
pacman-key --init
pacman-key --populate archlinux
pacman-key --populate holo
pacman -Syu --noconfirm ipset iptables
cp /opt/zapret/system/zapret.service /usr/lib/systemd/system/zapret.service
systemctl daemon-reload
systemctl start zapret
echo "zapret запущен."
EOF

systemctl daemon-reload
systemctl start zapret
systemctl enable zapret
echo "Установка завершена. zapret теперь в папке /opt/zapret, папку в Загрузках можно удалить."