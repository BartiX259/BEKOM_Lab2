
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== Rozpoczynanie testów bezpieczeństwa (Narzędzia preinstalowane) ===${NC}"

check_tcp() {
    src_container=$1
    dest_ip=$2
    port=$3
    expected_result=$4 
    test_name=$5

    echo -n "TEST: $test_name ($src_container -> $dest_ip:$port) ... "

    docker exec $src_container nc -z -v -w 2 $dest_ip $port > /dev/null 2>&1
    result=$?

    if [ "$expected_result" == "ALLOW" ]; then
        if [ $result -eq 0 ]; then
            echo -e "${GREEN}PASS${NC}"
        else
            echo -e "${RED}FAIL (Oczekiwano połączenia)${NC}"
        fi
    else
        if [ $result -ne 0 ]; then
            echo -e "${GREEN}PASS (Zablokowane - OK)${NC}"
        else
            echo -e "${RED}FAIL (Połączenie przeszło!)${NC}"
        fi
    fi
}

check_ping() {
    src_container=$1
    dest_ip=$2
    expected_result=$3
    test_name=$4

    echo -n "TEST: $test_name ($src_container PING $dest_ip) ... "
    
    docker exec $src_container ping -c 1 -W 2 $dest_ip > /dev/null 2>&1
    result=$?

    if [ "$expected_result" == "ALLOW" ]; then
        if [ $result -eq 0 ]; then echo -e "${GREEN}PASS${NC}"; else echo -e "${RED}FAIL${NC}"; fi
    else
        if [ $result -ne 0 ]; then echo -e "${GREEN}PASS${NC}"; else echo -e "${RED}FAIL${NC}"; fi
    fi
}


check_tcp "employee-1" "10.0.20.10" "80" "ALLOW" "ZIELONY -> NIEBIESKI (HTTP)"

check_tcp "employee-1" "10.0.40.10" "5432" "DENY" "ZIELONY -> CZERWONY (DB)"

check_tcp "web-dmz" "10.0.40.10" "5432" "ALLOW" "NIEBIESKI -> CZERWONY (DB)"

check_ping "vulnerability-scanner" "10.0.30.10" "ALLOW" "MGMT -> ZIELONY"

check_ping "employee-1" "8.8.8.8" "ALLOW" "ZIELONY -> INTERNET"

check_ping "web-dmz" "10.0.30.10" "DENY" "NIEBIESKI -> ZIELONY"

echo -e "\n${YELLOW}=== Koniec testów ===${NC}"
