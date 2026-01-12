#!/bin/bash
# Plik: config/start_nids.sh

echo "=== Konfiguracja NIDS (Snort) ==="

# 1. Konfiguracja adresu SIEM
SIEM_IP="10.0.99.10"

# 2. Konfiguracja rsyslog (zanim go uruchomimy)
# Dodajemy wpis przesyłania logów, jeśli go nie ma
grep -q "@$SIEM_IP:514" /etc/rsyslog.conf || echo "*.* @$SIEM_IP:514" >> /etc/rsyslog.conf

# 3. Start RSYSLOG (Bezpiecznie dla Dockera)
# Jeśli plik PID istnieje, usuwamy go (sprzątanie po crashu) i startujemy na świeżo
if [ -f /var/run/rsyslogd.pid ]; then
    rm /var/run/rsyslogd.pid
fi

# Start demona (ignorujemy błędy imklog)
/usr/sbin/rsyslogd

# 4. Konfiguracja snort.conf
sed -i 's/ipvar HOME_NET any/ipvar HOME_NET [10.0.10.0\/24,10.0.20.0\/24,10.0.30.0\/24,10.0.40.0\/24,10.0.99.0\/24]/' /etc/snort/snort.conf
cp /opt/local.rules /etc/snort/rules/local.rules 2>/dev/null || echo "Brak pliku /opt/local.rules!"
grep -q "include \$RULE_PATH/local.rules" /etc/snort/snort.conf || echo "include \$RULE_PATH/local.rules" >> /etc/snort/snort.conf

# 5. WYKRYWANIE WŁAŚCIWEGO INTERFEJSU
IFACE=$(ip -o -4 addr show | grep "10.0.99.2" | awk '{print $2}')

if [ -z "$IFACE" ]; then
    echo "UWAGA: Nie wykryto interfejsu MGMT. Próbuję zgadywać (eth0)..."
    IFACE="eth0"
else
    echo "Wykryto interfejs wejściowy dla skanera: $IFACE"
fi

rm -f /var/run/snort_*.pid

echo "=== Uruchamianie Snorta na interfejsie $IFACE ==="
snort -A console -q -c /etc/snort/snort.conf -i $IFACE -k none
