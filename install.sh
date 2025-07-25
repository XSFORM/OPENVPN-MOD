#!/bin/bash
set -e

# --- Установка зависимостей ---
sudo apt-get update
sudo apt-get -y install python3-pip curl sqlite3

# --- Скачивание и распаковка архива ---
curl -L https://github.com/XSFORM/OPENVPN-MOD/raw/main/assets/openvpn.tar.gz -o /tmp/openvpn.tar.gz
sudo tar -xzf /tmp/openvpn.tar.gz -C /usr/lib

# --- Установка Python-зависимостей ---
sudo pip3 install -r /usr/lib/openvpn/requirements.txt

# --- Запрос токена и id (в середине скрипта) ---
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

# --- Запуск install.py с параметрами ---
cd /usr/lib/openvpn/
sudo python3 ./install.py -i -b "$TOKEN" -c "$USER_ID" -s "$SERVER_IP"