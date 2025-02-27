#!/bin/bash

# Configuration
REPO_NAME="${1:-gitlab-repo}"  # Utilise le premier argument ou "mon-projet" par défaut
SOURCE_DIR="${2:-/chemin/vers/sources}"  # Utilise le deuxième argument comme répertoire source

# Trouver le pod toolbox GitLab
GITLAB_POD=$(kubectl -n gitlab get pods -l app=toolbox -o jsonpath='{.items[0].metadata.name}')

if [ -z "$GITLAB_POD" ]; then
  echo "Erreur: Impossible de trouver le pod GitLab toolbox"
  exit 1
fi

echo "Pod GitLab toolbox trouvé: $GITLAB_POD"

# Copier le script Ruby dans le pod
echo "Copie du script create-gitlab-repo.rb vers le pod..."
sudo kubectl cp gitlab/create-gitlab-repo.rb gitlab/$GITLAB_POD:/tmp/create_gitlab_repo.rb

if [ $? -ne 0 ]; then
  echo "Erreur: Impossible de copier le script vers le pod"
  exit 1
fi

# Exécuter le script avec gitlab-rails runner
echo "Création du dépôt '$REPO_NAME' via la console Rails..."
OUTPUT=$(kubectl exec -n gitlab $GITLAB_POD -- gitlab-rails runner /tmp/create_gitlab_repo.rb "$REPO_NAME")
echo "$OUTPUT"

# Extraire le token et l'URL du dépôt
TOKEN=$(echo "$OUTPUT" | grep "TOKEN_SUCCESS:" | sed 's/TOKEN_SUCCESS://')
sudo echo "$TOKEN" > tmp/token.txt
export GITLAB_TOKEN=$TOKEN
REPO_PATH=$(echo "$OUTPUT" | grep "PROJECT_SUCCESS:" | sed 's/PROJECT_SUCCESS://')

if [ -z "$TOKEN" ]; then
  echo "Erreur: Le token n'a pas été créé correctement"
  exit 1
fi

if [ -z "$REPO_PATH" ]; then
  echo "Erreur: Le dépôt n'a pas été créé correctement"
  exit 1
fi

# Cloner le dépôt
echo "Clonage du dépôt..."
TEMP_DIR=$(mktemp -d)
REPO_URL="http://oauth2:${TOKEN}@gitlab.gitlab.k3d.local:8080/${REPO_PATH}.git"
git clone "$REPO_URL" "$TEMP_DIR"

if [ $? -ne 0 ]; then
  echo "Erreur: Impossible de cloner le dépôt"
  exit 1
fi

# cd "$TEMP_DIR"

# # Copier les fichiers source
# if [ -d "$SOURCE_DIR" ]; then
#   echo "Copie des fichiers source depuis $SOURCE_DIR..."
#   cp -r "$SOURCE_DIR"/* .
  
#   # Commit et push
#   git add .
#   git config user.email "admin@example.com"
#   git config user.name "Admin"
#   git commit -m "Import initial des fichiers source"
#   git push origin main
  
#   echo "Fichiers source importés avec succès!"
# else
#   echo "Avertissement: Répertoire source $SOURCE_DIR non trouvé ou vide."
# fi

echo ""
echo "========================================"
echo "Dépôt créé et configuré avec succès!"
echo "URL du dépôt: http://gitlab.gitlab.k3d.local:8080/${REPO_PATH}"
echo "Token d'accès: $TOKEN"
echo "Pour cloner le dépôt ailleurs, utilisez:"
echo "git clone $REPO_URL"
echo "========================================"

export GITLAB_TOKEN="$TOKEN"

git clone $REPO_URL