#!/bin/env bash
# This is used to modify DHCP Ubuntu virtual machines to ones static ips.
sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bkp

IP_ADDR=$(ifconfig | awk '{if ($1 == "inet" && $2 ~ /192/) print $2}')
echo Detected ip address: $IP_ADDR
cat <<EOF | sudo tee /etc/netplan/00-installer-config.yaml
network:
  ethernets:
    enp0s3:
      dhcp4: no
      addresses: [$IP_ADDR/24]
      gateway4: 192.168.1.1
      nameservers:
              addresses: [8.8.8.8,8.8.4.4]
  version: 2
EOF
sudo netplan --debug apply
