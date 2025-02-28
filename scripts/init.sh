#!/bin/bash

# Definir variáveis
DOCKER_COMPOSE_FILE="/home/cadore/batch-upgrade-appliance/docker-compose.yaml"

# Criar namespaces de rede
echo "Criando namespaces de rede..."
sudo ip netns add tftp1
sudo ip netns add tftp2
sudo ip netns add tftp3

# Mover VLANs para os namespaces
echo "Movendo VLANs para os namespaces..."
sudo ip link set vlan10 netns tftp1
sudo ip link set vlan20 netns tftp2
sudo ip link set vlan30 netns tftp3

# Configurar IPs e rotas dentro dos namespaces
echo "Configurando IPs e rotas..."
sudo ip netns exec tftp1 ip addr add 10.10.10.2/24 dev vlan10
sudo ip netns exec tftp1 ip link set vlan10 up
sudo ip netns exec tftp1 ip route add default via 10.10.10.1 dev vlan10

sudo ip netns exec tftp2 ip addr add 10.10.10.2/24 dev vlan20
sudo ip netns exec tftp2 ip link set vlan20 up
sudo ip netns exec tftp2 ip route add default via 10.10.10.1 dev vlan20

sudo ip netns exec tftp3 ip addr add 10.10.10.2/24 dev vlan30
sudo ip netns exec tftp3 ip link set vlan30 up
sudo ip netns exec tftp3 ip route add default via 10.10.10.1 dev vlan30

# Instalar Docker e Docker Compose se necessário
echo "Verificando instalação do Docker..."
if ! command -v docker &> /dev/null
then
    echo "Docker não encontrado, abortando..."
    exit 1
fi

# Rodar os containers dentro dos namespaces
echo "Iniciando containers..."
sudo ip netns exec tftp1 docker compose -f $DOCKER_COMPOSE_FILE up -d tftpserver1
sudo ip netns exec tftp2 docker compose -f $DOCKER_COMPOSE_FILE up -d tftpserver2
sudo ip netns exec tftp3 docker compose -f $DOCKER_COMPOSE_FILE up -d tftpserver3

echo "Configuração concluída!"
