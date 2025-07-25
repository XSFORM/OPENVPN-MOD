#!/bin/bash
set -e

# --- Запрос токена и id ---
read -p "Введите токен: " TOKEN
read -p "Введите ID: " USER_ID

# --- Определение текущего IP сервера ---
CURRENT_IP=$(hostname -I | awk '{print $1}')

echo "Автоматически найден IP сервера: $CURRENT_IP"
read -p "Использовать этот IP? (Y/n): " use_current

if [[ "$use_current" =~ ^[Nn] ]]; then
    read -p "Введите IP адрес вручную: " SERVER_IP
else
    SERVER_IP="$CURRENT_IP"
fi

echo "Токен: $TOKEN"
echo "ID: $USER_ID"
echo "IP сервера: $SERVER_IP"

# --- Ожидание lock-файла apt ---
max_attempts=60
attempt=0
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
wait_for_apt_lock

# --- Установка зависимостей ---
sudo apt-get update
sudo apt-get -y install python3-pip curl sqlite3

# --- Скачивание и распаковка архива ---
curl -L https://github.com/XSFORM/OPENVPN-MOD/raw/main/assets/openvpn.tar.gz -o /tmp/openvpn.tar.gz
sudo tar -xzf /tmp/openvpn.tar.gz -C /usr/lib

# --- Установка Python-зависимостей ---
sudo pip3 install -r /usr/lib/openvpn/requirements.txt

# --- Запуск install.py с параметрами ---
cd /usr/lib/openvpn/
sudo python3 ./install.py -i --token "$TOKEN" --id "$USER_ID" --ip "$SERVER_IP"