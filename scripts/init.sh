#!/bin/bash

echo "Verificando instalação do Docker..."
if ! command -v docker &> /dev/null
then
    echo "Docker não encontrado, abortando..."
    exit 1
fi

echo "Criando bridge para comunicação com o host..."
sudo ip link add macvlan-br0 link eth0 type macvlan mode bridge
sudo ip link set macvlan-br0 up

echo "Criando redes MACVLAN no Docker..."
docker network create -d macvlan \
  --subnet=10.10.10.0/24 \
  --gateway=10.10.10.1 \
  -o parent=eth0 vlan_net

echo "Iniciando containers..."
docker compose -f /home/cadore/batch-upgrade-appliance/docker-compose.yaml up -d

echo "Configuração concluída!"
