GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

# Définition de la cible par défaut qui exécute rm-token puis up
all: rm-token up ssh-server

# Démarre les VMs
up:
	@echo "${YELLOW}Starting the VMs + k3s server and agent...${NC}"
	@vagrant up
	@echo "${GREEN}VMs started${NC}"

# Arrête les VMs
down:
	@echo "${YELLOW}Turning off the VM..${NC}."
	@vagrant halt
	@echo "${GREEN}VM turned off${NC}"

# Nettoie l'environnement en supprimant les VMs
clean: rm-token
	@echo "${YELLOW}Cleaning up the VMs...${NC}"
	@vagrant destroy -f
	@echo "${GREEN}VMs destroyed${NC}"

# Supprime le fichier node-token s'il existe
rm-token:
	@echo "${YELLOW}Removing node-token..${NC}."
	@if [ -f ./node-token ]; then \
		rm -rf ./node-token; \
		echo "${GREEN}node-token removed${NC}"; \
	else \
		echo "${YELLOW}node-token not found${NC}"; \
	fi

ssh-server:
	@echo "${YELLOW}Connecting via SSH to the server...${NC}"
	@vagrant ssh server