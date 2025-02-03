# #!/bin/bash

# # Mise à jour des paquets
# echo "Mise à jour du système..."
# apt-get update
# apt-get upgrade -y

# # Installation des dépendances de base
# echo "Installation des dépendances..."
# apt-get install -y \
#     curl \

# # server is assumed below because there is no K3S_URL
# curl -sfL https://get.k3s.io | sh -s server --flannel-iface=eth1 --token test --write-kubeconfig-mode 644
# # while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
# #     sleep 1
# #     echo "En attente de la création du token..."
# # done

# # sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token

# # Vous pouvez ajouter d'autres installations et configurations...

#!/bin/sh

sudo apt-get update
sudo apt-get install -y curl net-tools
curl -sfL https://get.k3s.io | sh -s server --flannel-iface=eth1 --token test --write-kubeconfig-mode 644