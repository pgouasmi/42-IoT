GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

CLUSTER_NAME := IoT-Part3

# Définition de la cible par défaut qui exécute rm-token puis up
all: up

# Démarre les VMs
up:
	@echo "${YELLOW}Creating Cluster ${CLUSTER_NAME} with k3d...${NC}"
	k3d cluster create ${CLUSTER_NAME}
	@echo "${GREEN}Cluster ${CLUSTER_NAME} successfully created!\n${NC}"
	@echo "${YELLOW}Creating 'argocd' namespace in ${CLUSTER_NAME} cluster...${NC}"
	kubectl create namespace argocd
	@echo "${GREEN}argocd namespace successfully created!\n${NC}"
	@echo "${YELLOW}Creating 'dev' namespace in ${CLUSTER_NAME} cluster...${NC}"
	kubectl create namespace dev
	@echo "${GREEN}dev namespace successfully created!\n${NC}"
	@echo "${YELLOW}Installing argocd in cluster ${CLUSTER_NAME}...${NC}"
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "${GREEN}argocd successfully installed in ${CLUSTER_NAME}!\n${NC}"
	@echo "${YELLOW} Deploying agrocd...${NC}"
	kubectl apply -f argocd.yaml
	@echo "${GREEN}agrocd up!${NC}"
	

get-password:
	@echo "${GREEN}cdagro web password:${NC}"
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

get-agrocd-url:
	@echo "${GREEN}agrocd web client URL: ${NC}"
	kubectl get svc argocd-server -n argocd
	@echo "${GREEN}Port: 8080"
# Arrête les VMs
down:
	@echo "${YELLOW}Turning off the VM..${NC}."
	@vagrant halt
	@echo "${GREEN}VM turned off${NC}"

# Nettoie l'environnement en supprimant les VMs
clean:
	@echo "${YELLOW}Cleaning up the cluster and docker resources${NC}"
	k3d cluster delete ${CLUSTER_NAME}
	@echo "${GREEN}Cluster ${CLUSTER_NAME} successfully deleted!\n${NC}"



ssh-server:
	@echo "${YELLOW}Connecting via SSH to the server...${NC}"
	@vagrant ssh server