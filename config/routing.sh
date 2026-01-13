
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'


set_gateway() {
    container=$1
    gw_ip=$2
    
    echo -n "Konfiguracja kontenera $container (GW -> $gw_ip)... "
    
    if ! docker ps --format '{{.Names}}' | grep -q "^$container$"; then
        echo -e "${RED}KONTENER NIE DZIAŁA${NC}"
        return
    fi

    docker exec $container ip route del default > /dev/null 2>&1
    
    docker exec $container ip route add default via $gw_ip > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}BŁĄD${NC}"
    fi
}


set_gateway "employee-1" "10.0.30.2"

set_gateway "web-dmz" "10.0.20.2"

set_gateway "db-backend" "10.0.40.2"

set_gateway "dns-main" "10.0.10.2"

set_gateway "vulnerability-scanner" "10.0.99.2"

set_gateway "siem-manager" "10.0.99.2"

set_gateway "branch-host" "10.50.0.2"
