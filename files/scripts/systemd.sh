#!/bin/bash

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
