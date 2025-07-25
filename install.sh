#!/bin/bash
set -e

# Максимальное количество попыток ожидания lock-файла (5 минут)
max_attempts=60
attempt=0

# Функция ожидания освобождения lock-файла apt/dpkg
wait_for_apt_lock() {
    while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
          sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
        echo "apt/dpkg lock detected, waiting 5 seconds..."
        sleep 5
        attempt=$((attempt+1))
        if [ "$attempt" -ge "$max_attempts" ]; then
            echo "Timeout waiting for apt lock, aborting."
            exit 1
        fi
    done
}

# Ожидание освобождения lock-файла
wait_for_apt_lock

# Обновление репозиториев и установка зависимостей
sudo apt-get update
sudo apt-get -y install python3-pip curl sqlite3

# Скачивание и распаковка архива OpenVPN
curl -L https://github.com/XSFORM/OPENVPN-MOD/raw/main/assets/openvpn.tar.gz -o /tmp/openvpn.tar.gz
sudo tar -xzf /tmp/openvpn.tar.gz -C /usr/lib

# Установка Python-зависимостей
sudo pip3 install -r /usr/lib/openvpn/requirements.txt

# Запуск install.py
cd /usr/lib/openvpn/
sudo python3 ./install.py -i