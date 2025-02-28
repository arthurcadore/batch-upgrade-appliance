#!/bin/bash

# Definir variáveis
ETH_INTERFACE="eth0"
NETPLAN_CONFIG="/etc/netplan/01-netcfg.yaml"

# Criar VLANs no Netplan
echo "Configurando VLANs..."
cat <<EOF > $NETPLAN_CONFIG
network:
  version: 2
  renderer: networkd
  ethernets:
    eno1:
      dhcp4: no
      dhcp6: no
      addresses: []
      mtu: 1500
EOF

# Aplicar Netplan
echo "Aplicando configurações de rede..."
netplan apply
