#!/bin/sh

helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --values gitlab/gitlab-values.yml \
  --timeout 600s

echo "Installing, waiting for pods to be ready..."

kubectl wait --for=condition=ready pod -l app=webservice -n gitlab --timeout=20m

if [ $? -eq 0 ]; then
  echo "GitLab is ready!"
else
  echo "Gitlab installation failed."
fi