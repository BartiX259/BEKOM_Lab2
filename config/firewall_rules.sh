
WAN_IFACE=$(ip route show default | awk '/default/ {print $5}' | head -n 1)

if [ -z "$WAN_IFACE" ]; then
    WAN_IFACE=$(ip -o -4 addr show | grep "172.20.0" | awk '{print $2}' | head -n 1)
fi

NET_YELLOW="10.0.10.0/24"
NET_BLUE="10.0.20.0/24"
NET_GREEN="10.0.30.0/24"
NET_RED="10.0.40.0/24"
NET_MGMT="10.0.99.0/24"

IP_DNS="10.0.10.10"
IP_WEB="10.0.20.10"
IP_SIEM="10.0.99.10"

iptables -F
iptables -X
iptables -t nat -F

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT


iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

iptables -A FORWARD -s $NET_BLUE -d $NET_GREEN -j DROP

iptables -t nat -A POSTROUTING -o $WAN_IFACE -j MASQUERADE
iptables -t nat -A PREROUTING -i $WAN_IFACE -p tcp --dport 80 -j DNAT --to-destination $IP_WEB:80

iptables -A FORWARD -s $NET_GREEN -d $IP_DNS -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s $NET_GREEN -d $IP_DNS -p tcp --dport 53 -j ACCEPT

iptables -A FORWARD -s $IP_DNS -o $WAN_IFACE -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s $IP_DNS -o $WAN_IFACE -p tcp --dport 53 -j ACCEPT

iptables -A FORWARD -i $WAN_IFACE -d $IP_DNS -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -i $WAN_IFACE -d $IP_DNS -p tcp --dport 53 -j ACCEPT

iptables -A FORWARD -s $NET_GREEN -o $WAN_IFACE -j ACCEPT

iptables -A FORWARD -s $NET_YELLOW -o $WAN_IFACE -j ACCEPT

iptables -A FORWARD -i $WAN_IFACE -d $NET_BLUE -p tcp -m multiport --dports 80,443 -j ACCEPT

iptables -A FORWARD -s $NET_GREEN -d $NET_BLUE -p tcp -m multiport --dports 80,443 -j ACCEPT

iptables -A FORWARD -s $NET_BLUE -d $NET_RED -p tcp --dport 5432 -j ACCEPT

iptables -A FORWARD -s 10.0.99.20 -j ACCEPT

iptables -A FORWARD -d $IP_SIEM -p udp --dport 514 -j ACCEPT
iptables -A FORWARD -d $IP_SIEM -p tcp --dport 1514 -j ACCEPT

iptables -A FORWARD -m limit --limit 5/min -j LOG --log-prefix "FW-DROP: " --log-level 4

