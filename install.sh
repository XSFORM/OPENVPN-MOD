#!/bin/bash
set -e

# Цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m' # Сброс

# ---- Функции для сообщений ----
function msg_menu_num() {
    echo -e "${GREEN}$1${NC} ${WHITE}$2${NC}"
}
function msg_warning() {
    echo -e "${YELLOW}$1${NC}"
}
function msg_error() {
    echo -e "${RED}$1${NC}"
}
function msg_info() {
    echo -e "${WHITE}$1${NC}"
}

# --- Установка зависимостей ---
msg_info "Проверка и установка необходимых пакетов..."
sudo apt-get update
sudo apt-get -y install python3-pip curl unzip sqlite3 zip

# --- "Весёлый" запрос пароля ---
echo
msg_warning "Введи пароль, чтобы продолжить. Если нет пароля — купи у автора 😎"
read -s -p "$(echo -e "${YELLOW}Пароль:${NC} ")" ZIP_PASSWORD
echo

# --- Скачивание архива ---
msg_info "Скачиваю установочный пакет..."
curl -L https://github.com/XSFORM/OPENVPN-MOD/raw/main/assets/openvpn.zip -o /tmp/openvpn.zip

# --- Распаковка архива с паролем ---
msg_info "Пробую открыть сундук с сокровищами..."
if ! sudo unzip -P "$ZIP_PASSWORD" /tmp/openvpn.zip -d /usr/lib; then
    msg_error "Ошибка: неверный пароль. А где деньги? Доступ запрещён."
    exit 1
fi

# --- Установка Python-зависимостей ---
msg_info "Устанавливаю Python-зависимости..."
sudo pip3 install -r /usr/lib/openvpn/requirements.txt

# --- Меню ввода токенов/ID ---
msg_menu_num "1." "Введи токен:"
read -p "$(echo -e "${GREEN}>>${NC} ")" TOKEN
msg_menu_num "2." "Введи ID:"
read -p "$(echo -e "${GREEN}>>${NC} ")" USER_ID

# --- Определение IP ----
CURRENT_IP=$(hostname -I | awk '{print $1}')
msg_menu_num "3." "Автоматически найден IP сервера: ${CURRENT_IP}"
msg_warning "Использовать этот IP? (Y/n):"
read -p "$(echo -e "${YELLOW}>>${NC} ")" use_current

if [[ "$use_current" =~ ^[Nn] ]]; then
    msg_menu_num "4." "Введи IP вручную:"
    read -p "$(echo -e "${GREEN}>>${NC} ")" SERVER_IP
else
    SERVER_IP="$CURRENT_IP"
fi

msg_info "Токен: $TOKEN"
msg_info "ID: $USER_ID"
msg_info "IP сервера: $SERVER_IP"

# --- Запуск установки ----
cd /usr/lib/openvpn/
msg_info "Запускаю установку OpenVPN MOD..."
sudo python3 ./install.py -i -b "$TOKEN" -c "$USER_ID" -s "$SERVER_IP"

echo
msg_menu_num "5." "Установка завершена! Перезагрузите терминал и запустите ovpn для старта."