FROM ubuntu:22.04

# Unikamy interaktywnych pytań podczas instalacji (np. o strefę czasową)
ENV DEBIAN_FRONTEND=noninteractive

# Instalacja narzędzi sieciowych i diagnostycznych
RUN apt-get update && apt-get install -y \
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
    strongswan \
    libcharon-extra-plugins \
    kmod \
    wireguard \
    openresolv \
    && rm -rf /var/lib/apt/lists/*

# Ustawiamy katalog roboczy
WORKDIR /root
