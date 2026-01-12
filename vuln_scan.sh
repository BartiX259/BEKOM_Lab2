#!/bin/bash
echo "=== [AUDYT] Rozpoczynanie skanowania podatności (NMAP) ==="
echo "Źródło: vulnerability-scanner (MGMT)"
echo "Cel:    web-dmz (NIEBIESKI - 10.0.20.10)"

# -sS: TCP SYN Scan (półotwarte, cichsze)
# -sV: Detekcja wersji usług
docker exec -it vulnerability-scanner nmap -sS -sV -p 80,443,22,8080,5432 10.0.20.10

echo "=== [AUDYT] Koniec skanowania ==="
