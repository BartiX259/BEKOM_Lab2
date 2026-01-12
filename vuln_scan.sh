#!/bin/bash
# Skrypt uruchamiany na hoście (Twój komputer), wywołuje skan w kontenerze
# Użycie: bash scripts/run_vuln_scan.sh

echo "=== [AUDYT] Rozpoczynanie skanowania podatności (NMAP) ==="
echo "Źródło: vulnerability-scanner (MGMT)"
echo "Cel:    web-dmz (NIEBIESKI - 10.0.20.10)"

# Skanowanie:
# -sS: TCP SYN Scan (półotwarte, cichsze)
# -sV: Detekcja wersji usług
# -p-: Skanuj wszystkie 65535 portów (sprawdzamy czy firewall nie przepuszcza śmieci)
# --script vulners: (Opcjonalnie, jeśli nmap w kali ma to pobrane, w wersji basic użyjemy detection)

docker exec -it vulnerability-scanner nmap -sS -sV -p 80,443,22,8080,5432 10.0.20.10

echo "=== [AUDYT] Koniec skanowania ==="
