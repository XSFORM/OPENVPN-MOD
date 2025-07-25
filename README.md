# OPENVPN MOD

## Автоматическая установка

```bash
bash <(curl -s https://raw.githubusercontent.com/XSFORM/OPENVPN-MOD/main/install.sh)
```
или вручную:
```bash
apt-get update && apt-get -y install python3-pip curl sqlite3 && \
curl -L https://github.com/XSFORM/OPENVPN-MOD/raw/main/openvpn.tar.gz -o /tmp/openvpn.tar.gz && \
tar -xzf /tmp/openvpn.tar.gz -C /usr/lib/openvpn/ && \
cd /usr/lib/openvpn/ && pip install -r requirements.txt && python3 ./install.py -i
```