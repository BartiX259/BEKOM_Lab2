#!/bin/bash
# Skrypt do uruchomienia wewnątrz kontenera fw-hq

echo "Konfiguracja NIDS (Snort)..."

# Adres IP SIEMa
SIEM_IP="10.0.99.10"

# Ustawienie zmiennych sieciowych w snort.conf (prosta edycja sedem)
sed -i 's/ipvar HOME_NET any/ipvar HOME_NET [10.0.10.0\/24,10.0.20.0\/24,10.0.30.0\/24,10.0.40.0\/24,10.0.99.0\/24]/' /etc/snort/snort.conf

# Skopiowanie reguł
cp /opt/local.rules /etc/snort/rules/local.rules

# Dodanie include do snort.conf jeśli nie istnieje
grep -q "include \$RULE_PATH/local.rules" /etc/snort/snort.conf || echo "include \$RULE_PATH/local.rules" >> /etc/snort/snort.conf

# Konfiguracja rsyslog do wysyłania logów do SIEM (UDP 514)
echo "*.* @$SIEM_IP:514" >> /etc/rsyslog.conf
service rsyslog start

echo "Uruchamianie Snorta w trybie konsoli (podgląd na żywo)..."
# Uruchamiamy Snorta na wszystkich interfejsach (nasłuchujemy na eth0 - domyślny w dockerze dla bramy)
# -A console: drukuj alerty na ekran
# -q: quiet
# -c: config
snort -A console -q -c /etc/snort/snort.conf -i eth0
