#!/bin/bash

# Definir variáveis
DOCKER_COMPOSE_FILE="/home/cadore/batch-upgrade-appliance/docker-compose.yaml"

# Verificar se o Docker está instalado
echo "Verificando instalação do Docker..."
if ! command -v docker &> /dev/null
then
    echo "Docker não encontrado, abortando..."
    exit 1
fi

# Criar redes MacVLAN no Docker
echo "Criando redes MacVLAN no Docker..."
docker network create -d macvlan \
  --subnet=10.10.10.0/24 \
  --gateway=10.10.10.1 \
  -o parent=vlan10 vlan10

docker network create -d macvlan \
  --subnet=10.10.10.0/24 \
  --gateway=10.10.10.1 \
  -o parent=vlan20 vlan20

docker network create -d macvlan \
  --subnet=10.10.10.0/24 \
  --gateway=10.10.10.1 \
  -o parent=vlan30 vlan30

# Iniciar containers
echo "Iniciando containers..."
docker compose -f $DOCKER_COMPOSE_FILE up

echo "Configuração concluída!"
