#!/bin/sh

sudo apt-get update
sudo apt-get install -y curl net-tools
curl -sfL https://get.k3s.io | sh -s server --flannel-iface=eth1 --write-kubeconfig-mode 644
kubectl apply -f /vagrant/confs