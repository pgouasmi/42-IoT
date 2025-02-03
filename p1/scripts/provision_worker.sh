#!/bin/bash

echo "Mise à jour du système..."
apt-get update
apt-get upgrade -y

echo "Installation des dépendances..."
apt-get install -y \
    curl \

curl -sfL https://get.k3s.io | sh -s agent --server https://192.168.56.110:6443 --node-ip 192.168.56.111 --token $(cat /vagrant/node-token)

