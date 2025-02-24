GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

CLUSTER_NAME := IoT-Bonus

# Définition de la cible par défaut qui exécute rm-token puis up
all: up get-details

install-deps:
	@echo "${YELLOW}Installing k3d...${NC}"
	curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	@echo "${GREEN}k3d successfully installed!\n${NC}"
	@echo "${YELLOW}Installing Docker...${NC}"
	sh deps/docker-install.sh
	@echo "${GREEN}Docker successfully installed!\n${NC}"
	@echo "${YELLOW}Installing kubectl...${NC}"
	sh deps/kubectl-install.sh
	@echo "${GREEN}kubectl successfully installed!\n${NC}"
	@echo "${YELLOW}Installing helm..."
	sh deps/helm-install.sh
	@echo "${GREEN}helm successfully installed!\n${NC}"
	@echo "${YELLOW}Getting gitlab helm chart...${NC}"
	sh gitlab/get-gitlab-chart.sh
	@echo "${GREEN}Gitlab's helm chart successfully pulled!${NC}"



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
	kubectl apply -f argocd/argocd.yaml
	@echo "${GREEN}agrocd up!${NC}"

	@echo "${YELLOW}Creating Gitlab namespace...${NC}"
	sudo kubectl apply -f gitlab/namespace.yml
	@echo "${GREEN}gitlab namespace successfully created!${NC}"

	@echo "${YELLOW}Deploying Gitlab...${NC}"
	sh gitlab/install-gitlab-chart-cluster.sh
	@echo "${GREEN}Gitlab successfully deployed!${NC}"


argocd-forward:
	sudo kubectl port-forward svc/argocd-server -n argocd 8080:443

get-details: get-argocd-url get-password get-app-url

get-password:
	@echo "${GREEN}cdagro web password:${NC}"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo "\n"

get-argocd-url:
	@echo "${GREEN}agrocd web client URL: ${NC}"
	@kubectl get svc argocd-server -n argocd
	@echo "${GREEN}Port: 8080"

get-app-url:
	@echo "${GREEN}App URL:\n${NC}"
	sudo kubectl get service -n dev
# Arrête les VMs
down:
	@echo "${YELLOW}Turning off the VM..${NC}."
	@vagrant halt
	@echo "${GREEN}VM turned off${NC}"

# Nettoie l'environnement en supprimant les VMs
clean:
	@echo "${YELLOW}Cleaning up the cluster and docker resources${NC}"
	sudo k3d cluster delete ${CLUSTER_NAME}
	@echo "${GREEN}Cluster ${CLUSTER_NAME} successfully deleted!\n${NC}"


re: clean all



ssh-server:
	@echo "${YELLOW}Connecting via SSH to the server...${NC}"
	@vagrant ssh server