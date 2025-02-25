GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

CLUSTER_NAME := IoT-Bonus
GITLAB_REPO := http://gitlab.localhost:8080/root/IoT-Bonus
GITLAB_PORT := 8081


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


up: setup-cluster setup-gitlab gitlab-forward setup-gitlab-repo setup-argocd


setup-cluster:
	@echo "${YELLOW}Setting up Cluster and its namespaces${NC}"

	@echo "${YELLOW}Creating Cluster ${CLUSTER_NAME} with k3d...${NC}"
	k3d cluster create ${CLUSTER_NAME}
	@echo "${GREEN}Cluster ${CLUSTER_NAME} successfully created!\n${NC}"

	@echo "${YELLOW}Creating 'argocd' namespace in ${CLUSTER_NAME} cluster...${NC}"
	kubectl create namespace argocd
	@echo "${GREEN}argocd namespace successfully created!\n${NC}"

	@echo "${YELLOW}Creating 'dev' namespace in ${CLUSTER_NAME} cluster...${NC}"
	kubectl create namespace dev
	@echo "${GREEN}dev namespace successfully created!\n${NC}"

	@echo "${YELLOW}Creating Gitlab namespace...${NC}"
	sudo kubectl apply -f gitlab/namespace.yml
	@echo "${GREEN}gitlab namespace successfully created!${NC}"

	@echo "${GREEN}Cluster infrastrcture built!\n\n${NC}"


setup-gitlab:
	@echo "${YELLOW}Deploying Gitlab...${NC}"
	sh gitlab/install-gitlab-chart-cluster.sh
	@echo "${GREEN}Gitlab successfully deployed!${NC}"


gitlab-forward:
	@echo "Starting Gitlab port-forwarding in background..."
	@nohup sudo kubectl port-forward -n gitlab service/gitlab-webservice-default $(GITLAB_PORT):8080 > gitlab-port-forward.log 2>&1 & echo $$! > .gitlab-port-forward.pid
	@echo "Port-forwarding started on localhost:$(GITLAB_PORT)"
	@echo "Check gitlab-port-forward.log for output"


gitlab-stop-forward:
	@if [ -f .gitlab-port-forward.pid ]; then \
		echo "Stopping port-forwarding process..."; \
		kill `cat .gitlab-port-forward.pid` || true; \
		rm .gitlab-port-forward.pid; \
	else \
		echo "No port-forwarding process found."; \
	fi


setup-gitlab-repo:
	@echo "${YELLOW}Setting up the Gitlab repo${NC}"
	sh gitlab/setup-gitlab-repo.sh
	@echo "${GREEN}Gitlab repo created!${NC}"


setup-argocd:
	@echo "${YELLOW}Installing argocd in cluster ${CLUSTER_NAME}...${NC}"
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "${GREEN}argocd successfully installed in ${CLUSTER_NAME}!\n${NC}"

	@echo "${YELLOW} Deploying agrocd...${NC}"
	kubectl apply -f argocd/argocd.yaml
	@echo "${GREEN}agrocd up!${NC}"



setup-sources: clone-github clone-gitlab copy-sources delete-original push-gitlab


clone-github:
	mkdir original-sources
	git clone https://github.com/pgouasmi/IoT-pgouasmi-p3.git original-sources/


clone-gitlab:
	mkdir gitlab-sources
	git clone ${GITLAB_REPO} gitlab-sources/


copy-sources:
	cp -r original-sources/* gitlab-sources/


delete-original:
	rm -rf original-sources

push-gitlab:
	cd gitlab-sources/ && git add . && git commit -m "Update sources" && git push


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

get-gitlab-details:
	@echo "${GREEN}Gitlab web client URL: ${NC}"
	@echo "http://localhost:8081${NC}"
	@echo "${GREEN}Username:${NC}"
	@echo "root"
	@echo "${GREEN}Password: ${NC}"
	@sudo kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode
	@echo "\n"

down:
	@echo "${YELLOW}Turning off the VM..${NC}."
	@vagrant halt
	@echo "${GREEN}VM turned off${NC}"

# Nettoie l'environnement en supprimant les VMs
clean: gitlab-stop-forward
	@echo "${YELLOW}Cleaning up the cluster and docker resources${NC}"
	sudo k3d cluster delete ${CLUSTER_NAME}
	@echo "${GREEN}Cluster ${CLUSTER_NAME} successfully deleted!\n${NC}"
	sudo rm -rf *gitlab-port-forward.log nohop.out 


re: clean all



ssh-server:
	@echo "${YELLOW}Connecting via SSH to the server...${NC}"
	@vagrant ssh server