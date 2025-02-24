#!/bin/sh

helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --values gitlab/gitlab-values.yml \
  --timeout 600s