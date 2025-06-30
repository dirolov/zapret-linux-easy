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

cat <<EOF > /usr/lib/systemd/system/zapret.service
[Unit]
Description=zapret
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/zapret
ExecStart=/bin/bash /opt/zapret/system/starter.sh
ExecStop=/bin/bash /opt/zapret/system/stopper.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start zapret
systemctl enable zapret
echo "Установка завершена. zapret теперь в папке /opt/zapret, папку в Загрузках можно удалить."