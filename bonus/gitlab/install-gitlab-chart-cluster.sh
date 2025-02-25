#!/bin/sh

helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --values gitlab/gitlab-values.yml \
  --timeout 600s

echo "Installing, waiting for pods to be ready..."

# Attendre que le pod webservice soit prêt (c'est généralement le dernier)
kubectl wait --for=condition=ready pod -l app=webservice -n gitlab --timeout=20m

# Vérifier si l'installation a réussi
if [ $? -eq 0 ]; then
  echo "GitLab is ready!"
else
  echo "Gitlab installation failed."
fi