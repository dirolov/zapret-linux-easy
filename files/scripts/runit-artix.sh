#!/bin/bash
mkdir -p /etc/runit/sv/zapret

cat <<EOF > /etc/runit/sv/zapret/run
#!/bin/sh
exec /opt/zapret/system/starter.sh
EOF

cat <<EOF > /etc/runit/sv/zapret/finish
#!/bin/sh
exec /opt/zapret/system/stopper.sh
EOF

	ln -s /etc/runit/sv/zapret /run/runit/service
    sv up zapret
    echo "Установка завершена. zapret теперь в папке /opt/zapret, папку в Загрузках можно удалить."
