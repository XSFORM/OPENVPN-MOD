#!/bin/bash
set -e

max_attempts=20
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if apt-get update; then
        break
    else
        echo "apt-get update failed due to lock, waiting 5 seconds..."
        sleep 5
        attempt=$((attempt+1))
    fi
done

apt-get -y install python3-pip curl sqlite3
curl -L https://github.com/XSFORM/OPENVPN-MOD/raw/main/assets/openvpn.tar.gz -o /tmp/openvpn.tar.gz
tar -xzf /tmp/openvpn.tar.gz -C /usr/lib
cd /usr/lib/openvpn/
pip install -r requirements.txt
python3 ./install.py -i