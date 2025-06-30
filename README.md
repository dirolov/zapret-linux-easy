# Однокнопочный zapret для Linux

1. Скачайте архив [https://github.com/ImMALWARE/zapret-linux-easy/releases/download/3/zapret.zip](https://github.com/ImMALWARE/zapret-linux-easy/releases/download/3/zapret.zip)
2. Распакуйте его
3. **Убедитесь, что у вас установлены пакеты `iptables` и `ipset`! Если нет — установите. Если вы не знаете как, спросите у ChatGPT!**
4. Откройте терминал в папке, куда архив был распакован
5. `./install.sh`

# Управление
## Systemd
Остановка: `sudo systemctl stop zapret`

Запуск после остановки: `sudo systemctl start zapret`

Отключение автозапуска (по умолчанию включен): `sudo systemctl disable zapret`

Включение автозапуска: `sudo systemctl enable zapret`

## OpenRC
Остановка: `sudo rc-service zapret stop`

Запуск после остановки: `sudo rc-service zapret start`

Включение автозапуска: `sudo rc-update add zapret`

Отключение автозапуска: `sudo rc-update del zapret`

# Списки доменов
Не работает какой-то заблокированный сайт? Попробуйте добавить его домен в `/opt/zapret/autohosts.txt`

Не работает незаблокированный сайт? Добавьте его домен в `/opt/zapret/ignore.txt`

## Протестировано на Kali, Ubuntu и Arch
