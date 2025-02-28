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
    $ETH_INTERFACE:
      dhcp4: no
  vlans:
    vlan10:
      id: 10
      link: $ETH_INTERFACE
      macaddress: "00:11:22:33:44:10"
      dhcp4: no
      addresses: [0.0.0.0/32]  # Adiciona um IP "nulo" para ativar a interface
    vlan20:
      id: 20
      link: $ETH_INTERFACE
      macaddress: "00:11:22:33:44:20"
      dhcp4: no
      addresses: [0.0.0.0/32]
    vlan30:
      id: 30
      link: $ETH_INTERFACE
      macaddress: "00:11:22:33:44:30"
      dhcp4: no
      addresses: [0.0.0.0/32]
EOF

# Aplicar Netplan
echo "Aplicando configurações de rede..."
netplan apply
