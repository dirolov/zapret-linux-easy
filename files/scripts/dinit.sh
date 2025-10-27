#!/bin/bash
cat <<EOF > /etc/dinit.d/zapret
type 	   = process
restart	   = true
depends-on = network.target
logfile    = /var/log/dinit/zapret.log
command    = /opt/zapret/system/starter.sh
EOF
    dinitctl start zapret
    dinitctl enable zapret
    echo "Установка завершена. zapret теперь в папке /opt/zapret, папку в Загрузках можно удалить."
