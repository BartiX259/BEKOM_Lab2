
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}=== AUDYT BEZPIECZEŃSTWA SIECI I USŁUG ===${NC}"

PASSED=0
FAILED=0

report_pass() {
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
}

report_fail() {
    echo -e "${RED}FAIL${NC} - $1"
    ((FAILED++))
}

check_tcp() {
    src=$1; dest=$2; port=$3; expect=$4; desc=$5
    echo -n "TEST TCP: $desc ($src -> $dest:$port) ... "
    
    docker exec $src nc -z -v -w 2 $dest $port > /dev/null 2>&1
    res=$?

    if [ "$expect" == "ALLOW" ]; then
        if [ $res -eq 0 ]; then report_pass; else report_fail "Oczekiwano połączenia"; fi
    else
        if [ $res -ne 0 ]; then report_pass; else report_fail "Połączenie udało się mimo blokady!"; fi
    fi
}

check_udp() {
    src=$1; dest=$2; port=$3; expect=$4; desc=$5
    echo -n "TEST UDP: $desc ($src -> $dest:$port) ... "
    
    docker exec $src nc -u -z -w 2 $dest $port > /dev/null 2>&1
    res=$?

    if [ "$expect" == "ALLOW" ]; then
        if [ $res -eq 0 ]; then report_pass; else report_fail "Oczekiwano połączenia UDP"; fi
    else
        if [ $res -ne 0 ]; then report_pass; else report_fail "Połączenie UDP udało się mimo blokady!"; fi
    fi
}

check_ping() {
    src=$1; dest=$2; expect=$3; desc=$4
    echo -n "TEST ICMP: $desc ($src -> $dest) ... "
    
    docker exec $src ping -c 1 -W 2 $dest > /dev/null 2>&1
    res=$?

    if [ "$expect" == "ALLOW" ]; then
        if [ $res -eq 0 ]; then report_pass; else report_fail "Brak odpowiedzi Ping"; fi
    else
        if [ $res -ne 0 ]; then report_pass; else report_fail "Ping przeszedł mimo blokady!"; fi
    fi
}

echo -e "\n${BLUE}--- [SEGMENTY] Komunikacja Biznesowa ---${NC}"
check_tcp "employee-1" "10.0.20.10" "80"   "ALLOW" "ZIELONY -> NIEBIESKI (Web HTTP)"
check_tcp "web-dmz"    "10.0.40.10" "5432" "ALLOW" "NIEBIESKI -> CZERWONY (App to DB)"
check_ping "employee-1" "10.0.10.10"       "ALLOW" "ZIELONY -> ŻÓŁTY (Ping DNS)"

echo -e "\n${BLUE}--- [BEZPIECZEŃSTWO] Izolacja i Zasada Najmniejszych Przywilejów ---${NC}"
check_tcp "employee-1" "10.0.40.10" "5432" "DENY"  "ZIELONY -> CZERWONY (Pracownik bezpośrednio do DB)"
check_tcp "employee-1" "10.0.20.10" "22"   "DENY"  "ZIELONY -> NIEBIESKI (Pracownik SSH do Web - zbędny port)"
check_ping "web-dmz"    "10.0.30.10"       "DENY"  "NIEBIESKI -> ZIELONY (DMZ nie może inicjować do LAN)"

echo -e "\n${BLUE}--- [INTERNET] Kontrola Wyjścia ---${NC}"
check_ping "employee-1" "8.8.8.8"    "ALLOW" "ZIELONY -> INTERNET (Pracownik ma Internet)"
check_ping "db-backend" "8.8.8.8"    "DENY"  "CZERWONY -> INTERNET (Baza Danych odcięta od świata - Wyciek Danych)"
check_ping "web-dmz"    "8.8.8.8"    "ALLOW" "NIEBIESKI -> INTERNET (Web Server aktualizacje)"

echo -e "\n${BLUE}--- [INFRASTRUKTURA] DNS i Logowanie (Wymagania SEC) ---${NC}"
check_udp "employee-1" "10.0.10.10" "53"  "ALLOW" "ZIELONY -> DNS (UDP 53)"
check_udp "web-dmz"    "10.0.10.10" "53"  "ALLOW" "NIEBIESKI -> DNS (UDP 53)"

check_udp "web-dmz"    "10.0.99.10" "1514" "ALLOW" "NIEBIESKI -> SIEM (Syslog)"
check_udp "fw-hq"      "10.0.99.10" "514" "ALLOW" "FW-HQ -> SIEM (Syslog)"

echo -e "\n${BLUE}--- [MGMT] Dostęp Administracyjny ---${NC}"
check_ping "vulnerability-scanner" "10.0.30.10" "ALLOW" "MGMT -> ZIELONY (Skaner widzi LAN)"
check_ping "vulnerability-scanner" "10.0.20.10" "ALLOW" "MGMT -> NIEBIESKI (Skaner widzi DMZ)"
check_ping "vulnerability-scanner" "10.0.40.10" "ALLOW" "MGMT -> CZERWONY (Skaner widzi DB)"

echo -e "\n${YELLOW}=== PODSUMOWANIE ===${NC}"
echo -e "Testów wykonano: $((PASSED + FAILED))"
if [ $FAILED -eq 0 ]; then
    echo -e "Wynik: ${GREEN}SUKCES${NC}"
else
    echo -e "Wynik: ${RED}WYKRYTO $FAILED BŁĘDÓW${NC}"
fi
