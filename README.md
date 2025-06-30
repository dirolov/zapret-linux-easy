# zapret для Linux

1. Скачайте и распакуйте архив https://github.com/ImMALWARE/zapret-linux-easy/archive/refs/heads/main.zip (либо `git clone https://github.com/ImMALWARE/zapret-linux-easy && cd zapret-linux-easy`)
2. **Убедитесь, что у вас установлены пакеты `iptables` и `ipset`! Если нет — установите. Если вы не знаете как, спросите у ChatGPT!**
3. Откройте терминал в папке, куда архив был распакован
4. `./install.sh`

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

Конфиг можно изменить в `/opt/zapret/config.txt` (перезапустите zapret после изменения)

Для проверки текущего конфига вы можете использовать `/opt/zapret/check.sh`

# Переменные в config.txt

`{hosts}` — подставит путь к `autohosts.txt`

`{ignore}` — подставит путь к `ignore.txt`

`{youtube}` — подставить путь к `youtube.txt`

`{quicgoogle}` — подставит путь к `system/quic_initial_www_google_com.bin`

`{tlsgoogle}` — подставит путь к `system/tls_clienthello_www_google_com.bin`
