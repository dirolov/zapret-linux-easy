cat <<EOF > /etc/init.d/zapret
#!/sbin/openrc-run

name="zapret"
description="zapret service"
command="/bin/bash"
command_args="/opt/zapret/system/starter.sh"
pidfile="/run/zapret.pid"

start_pre() {
    checkpath --directory /run
}

stop() {
    /bin/bash /opt/zapret/system/stopper.sh
}
EOF
    chmod +x /etc/init.d/zapret
    rc-update add zapret default
    rc-service zapret start
    echo "Установка завершена. zapret теперь в папке /opt/zapret, папку в Загрузках можно удалить."
