#!/bin/bash
set -e  # Przerwij skrypt, jeśli jakakolwiek komenda zwróci błąd

echo "--- [START] Konfiguracja DNS ---"

echo "1. Ustawianie routingu..."
# Sprawdzamy czy domyślna trasa istnieje, zanim ją usuniemy (żeby uniknąć błędu)
if ip route show | grep -q default; then
    ip route del default
fi
ip route add default via 10.0.10.2
echo "   Routing ustawiony na 10.0.10.2"

echo "2. Weryfikacja uprawnień..."
# Naprawa uprawnień do logów (na wypadek problemów z hostem)
chown -R root:root /var/log/named

echo "3. Uruchamianie BIND9..."
# exec powoduje, że BIND przejmuje PID 1 (ważne dla poprawnego zatrzymywania kontenera)
exec /usr/sbin/named -f -u root -4 -c /etc/bind/named.conf
