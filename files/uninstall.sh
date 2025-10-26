#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
    exit 1
fi

systemctl disable zapret
systemctl stop zapret
rc-update del zapret
rc-service zapret stop
rm -f /usr/lib/systemd/system/zapret.service
rm -f /etc/init.d/zapret
echo "Успешно удалено."
rm -rf /opt/zapret
