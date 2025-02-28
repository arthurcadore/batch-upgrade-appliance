#!/bin/bash

# Definir variáveis
ETH_INTERFACE="eth0"
NETPLAN_CONFIG="/etc/netplan/01-netcfg.yaml"
DOCKER_COMPOSE_FILE="/opt/tftp/docker-compose.yml"

# Criar VLANs no Netplan
echo "Configurando VLANs..."
cat <<EOF > $NETPLAN_CONFIG
network:
  version: 2
  renderer: networkd
  ethernets:
    $ETH_INTERFACE:
      dhcp4: no
  vlans:
    vlan10:
      id: 10
      link: $ETH_INTERFACE
      macaddress: "00:11:22:33:44:10"
      dhcp4: no
      addresses: []
    vlan20:
      id: 20
      link: $ETH_INTERFACE
      macaddress: "00:11:22:33:44:20"
      dhcp4: no
      addresses: []
    vlan30:
      id: 30
      link: $ETH_INTERFACE
      macaddress: "00:11:22:33:44:30"
      dhcp4: no
      addresses: []
EOF

# Aplicar Netplan
echo "Aplicando configurações de rede..."
netplan apply

# Criar namespaces de rede
echo "Criando namespaces de rede..."
ip netns add tftp1
ip netns add tftp2
ip netns add tftp3

# Mover VLANs para os namespaces
echo "Movendo VLANs para os namespaces..."
ip link set vlan10 netns tftp1
ip link set vlan20 netns tftp2
ip link set vlan30 netns tftp3

# Configurar IPs e rotas dentro dos namespaces
echo "Configurando IPs e rotas..."
ip netns exec tftp1 ip addr add 10.10.10.2/24 dev vlan10
ip netns exec tftp1 ip link set vlan10 up
ip netns exec tftp1 ip route add default via 10.10.10.1 dev vlan10

ip netns exec tftp2 ip addr add 10.10.10.2/24 dev vlan20
ip netns exec tftp2 ip link set vlan20 up
ip netns exec tftp2 ip route add default via 10.10.10.1 dev vlan20

ip netns exec tftp3 ip addr add 10.10.10.2/24 dev vlan30
ip netns exec tftp3 ip link set vlan30 up
ip netns exec tftp3 ip route add default via 10.10.10.1 dev vlan30

# Instalar Docker e Docker Compose se necessário
echo "Verificando instalação do Docker..."
if ! command -v docker &> /dev/null
then
    echo "Docker não encontrado, instalando..."
    apt update
    apt install -y docker.io docker-compose
    systemctl enable --now docker
fi

# Criar diretório do Docker Compose
mkdir -p /opt/tftp

# Criar arquivo docker-compose.yml
echo "Criando arquivo docker-compose.yml..."
cat <<EOF > $DOCKER_COMPOSE_FILE
version: '3.9'

services:
  tftp1:
    image: atmoz/tftp
    command: ["--secure"]
    volumes:
      - ./tftp-data:/var/tftpboot
    network_mode: "host"
    privileged: true

  tftp2:
    image: atmoz/tftp
    command: ["--secure"]
    volumes:
      - ./tftp-data:/var/tftpboot
    network_mode: "host"
    privileged: true

  tftp3:
    image: atmoz/tftp
    command: ["--secure"]
    volumes:
      - ./tftp-data:/var/tftpboot
    network_mode: "host"
    privileged: true
EOF

# Rodar os containers dentro dos namespaces
echo "Iniciando containers..."
ip netns exec tftp1 docker-compose -f $DOCKER_COMPOSE_FILE up -d tftp1
ip netns exec tftp2 docker-compose -f $DOCKER_COMPOSE_FILE up -d tftp2
ip netns exec tftp3 docker-compose -f $DOCKER_COMPOSE_FILE up -d tftp3

echo "Configuração concluída!"
