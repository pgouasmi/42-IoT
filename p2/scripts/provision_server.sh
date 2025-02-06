#!/bin/sh

sudo apt-get update
sudo apt-get install -y curl net-tools
curl -sfL https://get.k3s.io | sh -s server --flannel-iface=eth1 --write-kubeconfig-mode 644

# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

kubectl apply -f /vagrant/confs

alias k="kubectl"