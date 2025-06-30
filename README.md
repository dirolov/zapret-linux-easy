# zapret для Linux и Steam Deck

1. Скачайте и распакуйте архив https://github.com/ImMALWARE/zapret-linux-easy/archive/refs/heads/main.zip (либо `git clone https://github.com/ImMALWARE/zapret-linux-easy && cd zapret-linux-easy`)
2. **Убедитесь, что у вас установлены пакеты `iptables` и `ipset`! Если нет — установите. Если вы не знаете как, спросите у ChatGPT!**
3. Откройте терминал в папке, куда архив был распакован
4. `./install.sh`
(для Steam Deck `./steamdeck.sh`)

# Steam Deck
Создастся файл `after_update.sh` на Рабочем столе. Его нужно будет запускать после каждого обновления ОС.

# Управление
Остановка: `sudo systemctl stop zapret`

Запуск после остановки: `sudo systemctl start zapret`

Отключение автозапуска (по умолчанию включен): `sudo systemctl disable zapret`

Включение автозапуска: `sudo systemctl enable zapret`

# Списки доменов
Не работает какой-то заблокированный сайт? Попробуйте добавить его домен в `/opt/zapret/autohosts.txt`

Не работает незаблокированный сайт? Добавьте его домен в `/opt/zapret/ignore.txt`

Конфиг можно изменить в `/opt/zapret/config.txt` (перезапустите zapret после изменения)

# Переменные в config.txt

`{hosts}` — подставит путь к `autohosts.txt`

`{ignore}` — подставит путь к `ignore.txt`

`{youtube}` — подставить путь к `youtube.txt`

`{quicgoogle}` — подставит путь к `system/quic_initial_www_google_com.bin`

`{tlsgoogle}` — подставит путь к `system/tls_clienthello_www_google_com.bin`
