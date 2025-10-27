#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
    exit 1
fi

systemctl disable zapret
systemctl stop zapret
rm -f /usr/lib/systemd/system/zapret.service

rc-update del zapret
rc-service zapret stop
rm -f /etc/init.d/zapret

sv down zapret
rm -rf /etc/runit/sv/zapret
rm -rf /run/runit/service/zapret
echo "Успешно удалено."
rm -rf /opt/zapret
