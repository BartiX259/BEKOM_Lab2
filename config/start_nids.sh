#!/bin/bash
echo "=== Konfiguracja NIDS (Snort) ==="

SIEM_IP="10.0.99.10"

# Konfiguracja rsyslog dodajemy wpis przesyłania logów, jeśli go nie ma
grep -q "@$SIEM_IP:514" /etc/rsyslog.conf || echo "*.* @$SIEM_IP:514" >> /etc/rsyslog.conf

if [ -f /var/run/rsyslogd.pid ]; then
    rm /var/run/rsyslogd.pid
fi
/usr/sbin/rsyslogd

# Konfiguracja snort.conf
sed -i 's%ipvar HOME_NET any%ipvar HOME_NET [10.0.10.0/24,10.0.20.0/24,10.0.30.0/24,10.0.40.0/24,10.0.99.0/24]%' /etc/snort/snort.conf
cp /opt/local.rules /etc/snort/rules/local.rules 2>/dev/null || echo "Brak pliku /opt/local.rules"
grep -q "include \$RULE_PATH/local.rules" /etc/snort/snort.conf || echo "include \$RULE_PATH/local.rules" >> /etc/snort/snort.conf

# Wykrywanie właściwego interfejsu
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
