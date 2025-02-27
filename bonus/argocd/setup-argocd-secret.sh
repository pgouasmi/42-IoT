#!/bin/bash

TOKEN=$(sudo cat tmp/token.txt)

sudo cat > argocd/argocd-gitlab-secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-repo-credentials
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/gitlab-repo.git
  username: oauth2
  password: ${TOKEN}

EOF