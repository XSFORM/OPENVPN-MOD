#!/bin/bash
set -e

apt-get update
apt-get -y install python3-pip curl sqlite3
curl -L https://github.com/XSFORM/OPENVPN-MOD/raw/main/assets/openvpn.tar.gz -o /tmp/openvpn.tar.gz
tar -xzf /tmp/openvpn.tar.gz -C /usr/lib
cd /usr/lib/openvpn/
pip install -r requirements.txt
python3 ./install.py -i