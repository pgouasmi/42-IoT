GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

# Définition de la cible par défaut qui exécute rm-token puis up
all: up ssh-server

# Démarre les VMs
up:
	@echo "${YELLOW}Starting the VMs + k3s server...${NC}"
	@vagrant up
	@echo "${GREEN}VM started${NC}"

# Arrête les VMs
down:
	@echo "${YELLOW}Turning off the VM..${NC}."
	@vagrant halt
	@echo "${GREEN}VM turned off${NC}"

# Nettoie l'environnement en supprimant les VMs
clean:
	@echo "${YELLOW}Cleaning up the VMs...${NC}"
	@vagrant destroy -f
	@echo "${GREEN}VMs destroyed${NC}"


ssh-server:
	@echo "${YELLOW}Connecting via SSH to the server...${NC}"
	@vagrant ssh server