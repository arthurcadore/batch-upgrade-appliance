# batch-upgrade-appliance


### Configure the interface using netplan (Ubuntu 18.04 and later):

```yaml

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

```

```bash
sudo netplan apply
```

### Creating ip namespaces: 

```bash
ip netns add tftp1
ip netns add tftp2
ip netns add tftp3
```

### Move the interfaces to the namespaces:
```
ip link set vlan10 netns tftp1
ip link set vlan20 netns tftp2
ip link set vlan30 netns tftp3
```


### Setting Up IP and routes: 

```bash
sudo ip netns exec tftp1 ip addr add 10.10.10.2/24 dev vlan10
sudo ip netns exec tftp1 ip link set vlan10 up
sudo ip netns exec tftp1 ip route add default via 10.10.10.1 dev vlan10

sudo ip netns exec tftp2 ip addr add 10.10.10.2/24 dev vlan20
sudo ip netns exec tftp2 ip link set vlan20 up
sudo ip netns exec tftp2 ip route add default via 10.10.10.1 dev vlan20

sudo ip netns exec tftp3 ip addr add 10.10.10.2/24 dev vlan30
sudo ip netns exec tftp3 ip link set vlan30 up
sudo ip netns exec tftp3 ip route add default via 10.10.10.1 dev vlan30
```

### Init the containers using docker-compose
```bash
sudo ip netns exec tftp1 docker compose -f /home/cadore/batch-upgrade-appliance/docker-compose.yaml up -d tftpserver1
sudo ip netns exec tftp2 docker compose -f /home/cadore/batch-upgrade-appliance/docker-compose.yaml up -d tftpserver2
sudo ip netns exec tftp3 docker compose -f /home/cadore/batch-upgrade-appliance/docker-compose.yaml up -d tftpserver3
