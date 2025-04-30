GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

CLUSTER_NAME := IoT-Bonus
GITLAB_REPO := http://gitlab.localhost:8080/root/gitlab-repo
GITLAB_PORT := 8080


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


up: setup-cluster setup-gitlab create-tmp-dir gitlab-forward setup-gitlab-repo import-sources setup-argocd-secret setup-argocd argocd-forward


setup-cluster:
	@echo "${YELLOW}Setting up Cluster and its namespaces${NC}"

	@echo "${YELLOW}Creating Cluster ${CLUSTER_NAME} with k3d...${NC}"
	k3d cluster create ${CLUSTER_NAME} --api-port 6550 --port "80:80@loadbalancer" --port "443:443@loadbalancer"
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
	@echo "${GREEN}Gitlab successfully deployed!\n${NC}"


create-tmp-dir:
	@if [ ! -d "tmp" ]; then mkdir tmp; fi


gitlab-forward:
	@echo "${YELLOW}Starting Gitlab port-forwarding in background...${NC}"
	@nohup sudo kubectl port-forward -n gitlab service/gitlab-webservice-default $(GITLAB_PORT):8181 > tmp/gitlab-port-forward.log 2>&1 & echo $$! > tmp/.gitlab-port-forward.pid
	@echo "${GREEN}Port-forwarding started on localhost:$(GITLAB_PORT)${NC}"
	@echo "${GREEN}Check tmp/gitlab-port-forward.log for output\n${NC}"


gitlab-stop-forward:
	@if [ -f tmp/.gitlab-port-forward.pid ]; then \
		echo "Stopping port-forwarding process..."; \
		kill `cat tmp/.gitlab-port-forward.pid` || true; \
		rm tmp/.gitlab-port-forward.pid; \
		rm tmp/gitlab-port-forward.log; \
	else \
		echo "No port-forwarding process found."; \
	fi


setup-gitlab-repo:
	@echo "${YELLOW}Setting up the Gitlab repo${NC}"
	sh gitlab/setup-gitlab-repo.sh
	@echo "${GREEN}\nGitlab repo created!\n${NC}"


setup-argocd-secret:
	@echo "${YELLOW}\nSetting up the argocd secret${NC}"
	@sh argocd/setup-argocd-secret.sh
	@echo "${GREEN}ArgoCD secret created!\n${NC}"


setup-argocd:
	@echo "${YELLOW}Installing argocd in cluster ${CLUSTER_NAME}...${NC}"
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "${GREEN}argocd successfully installed in ${CLUSTER_NAME}!\n${NC}"

	@echo "${YELLOW} Deploying ArgoCD...${NC}"
	kubectl apply -f argocd/argocd-gitlab-secret.yaml
	kubectl apply -f argocd/argocd.yaml
	@echo "${GREEN}ArgoCD up!\n${NC}"


import-sources: clone-github copy-sources delete-original push-gitlab


clone-github:
	@echo "${YELLOW}Cloning the github repo...${NC}"
	mkdir original-sources
	git clone https://github.com/pgouasmi/IoT-pgouasmi-p3.git original-sources
	@echo "${GREEN}Github repo cloned!\n${NC}"


copy-sources:
	@echo "${YELLOW}Copying sources to gitlab repo...${NC}"
	cp -r original-sources/* gitlab-repo/
	@echo "${GREEN}Sources copied!\n${NC}"


delete-original:
	@echo "${YELLOW}Deleting original sources...${NC}"
	rm -rf original-sources
	@echo "${GREEN}Original sources deleted!\n${NC}"

push-gitlab:
	@echo "${YELLOW}Pushing sources to gitlab...${NC}"
	cd gitlab-repo/ && sudo git config user.email "admin@example.com" && sudo git config user.name "root" && sudo git add . && sudo git commit -m "Update sources" && sudo git push
	@echo "${GREEN}Sources pushed to Gitlab!\n${NC}"


argocd-forward:
	@sleep 10
	@echo "Starting ArgoCD port-forwarding in background..."
	@nohup sudo kubectl port-forward -n argocd service/argocd-server 8181:443 > tmp/argocd-port-forward.log 2>&1 & echo $$! > tmp/.argocd-port-forward.pid
	@echo "ArgoCD Port-forwarding started on localhost:8181"
	@echo "Check tmp/argocd-port-forward.log for output"


app-forward:
	@echo "Starting app port-forwarding in background..."
	@nohup sudo kubectl port-forward -n dev service/wil-playground-service 8888:8888 > tmp/app-port-forward.log 2>&1 & echo $$! > tmp/.app-port-forward.pid
	@echo "App Port-forwarding started on localhost:8888"
	@echo "Check tmp/app-port-forward.log for output"



argocd-stop-forward:
	@if [ -f tmp/.argocd-port-forward.pid ]; then \
		echo "Stopping ArgoCD port-forwarding process..."; \
		kill `cat tmp/.argocd-port-forward.pid` || true; \
		rm tmp/.argocd-port-forward.pid; \
		rm tmp/argocd-port-forward.log; \
	else \
		echo "No ArgoCD port-forwarding process found."; \
	fi


get-details: get-gitlab-details get-argocd-details


get-argocd-details: get-argocd-url get-argocd-password get-argocd-url get-app-url


get-argocd-password:
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


clean: gitlab-stop-forward argocd-stop-forward
	@echo "${YELLOW}Cleaning up the cluster and docker resources${NC}"
	sudo k3d cluster delete ${CLUSTER_NAME}
	@echo "${GREEN}Cluster ${CLUSTER_NAME} successfully deleted!\n${NC}"
	@if [ -d "tmp" ]; then sudo rm -rf tmp; fi
	@if [ -d "gitlab-repo" ]; then sudo rm -rf gitlab-repo; fi


re: clean all
