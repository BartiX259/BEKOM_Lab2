FROM ubuntu:22.04

# Unikamy interaktywnych pytań podczas instalacji (np. o strefę czasową)
ENV DEBIAN_FRONTEND=noninteractive

# Instalacja narzędzi sieciowych i diagnostycznych
# netcat-openbsd - kluczowy do testowania otwartych portów (nc)
# dnsutils - zawiera dig i nslookup
# traceroute - do śledzenia ścieżki pakietów
# tcpdump - do analizy ruchu (opcjonalnie)
RUN apt-get update && apt-get install -y \
    wireguard \
    iptables \
    iproute2 \
    iputils-ping \
    curl \
    netcat-openbsd \
    dnsutils \
    traceroute \
    tcpdump \
    nano \
    vim \
    snort \
    rsyslog \
    && rm -rf /var/lib/apt/lists/*

# Ustawiamy katalog roboczy
WORKDIR /root
