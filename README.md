# Inception-of-Things Project

## A project to get to learn DevOps technologies, especially Kubernetes, ArgoCD, Gitlab and CI/CD pipelines.

# BONUS PART:

A complete local Kubernetes development environment with GitLab and ArgoCD for continuous deployment.

## Overview

This project sets up a local Kubernetes cluster using k3d with the following components:
- **GitLab**: Self-hosted Git repository management
- **ArgoCD**: GitOps continuous delivery tool
- **Development Environment**: Dedicated namespace for application deployment

The entire infrastructure is defined as code and can be deployed with a single command.

## Prerequisites

- Linux-based operating system
- Sudo privileges
- Internet connection for downloading dependencies

## Quick Start

To set up the complete environment:

```bash
make all
```

This will install all dependencies, create the Kubernetes cluster, and deploy all components.

## Available Commands

### Installation

- `make install-deps`: Installs all required dependencies
  - k3d (Kubernetes cluster manager)
  - Docker
  - kubectl (Kubernetes CLI)
  - Helm (Kubernetes package manager)
  - GitLab Helm chart

### Cluster Management

- `make up`: Sets up the complete environment including:
  - `make setup-cluster`: Creates the Kubernetes cluster and necessary namespaces
  - `make setup-gitlab`: Deploys GitLab in the cluster
  - `make gitlab-forward`: Sets up port forwarding for GitLab
  - `make setup-gitlab-repo`: Initializes the GitLab repository
  - `make import-sources`: Imports application source code
  - `make setup-argocd`: Deploys ArgoCD and configures integration
  - `make argocd-forward`: Sets up port forwarding for ArgoCD

- `make clean`: Removes all created resources
  - Stops port forwarding
  - Deletes the Kubernetes cluster
  - Removes temporary directories

- `make re`: Combination of `clean` and `all` for a complete rebuild

### Source Code Management

- `make import-sources`: Imports application source code from GitHub
  - `make clone-github`: Clones the source repository
  - `make copy-sources`: Copies files to the GitLab repository
  - `make delete-original`: Removes the original cloned repository
  - `make push-gitlab`: Pushes code to the GitLab instance

### Port Forwarding

- `make gitlab-forward`: Sets up port forwarding for GitLab (port 8080)
- `make gitlab-stop-forward`: Stops GitLab port forwarding
- `make argocd-forward`: Sets up port forwarding for ArgoCD (port 8181)
- `make argocd-stop-forward`: Stops ArgoCD port forwarding

### Information Retrieval

- `make get-details`: Displays access information for all components
  - `make get-gitlab-details`: Shows GitLab URL, username and password
  - `make get-argocd-details`: Shows ArgoCD URL and credentials
  - `make get-app-url`: Shows the deployed application URL

## Architecture

The project creates a k3d Kubernetes cluster named "IoT-Bonus" with the following namespaces:
- `gitlab`: Contains the GitLab instance
- `argocd`: Contains the ArgoCD instance
- `dev`: Contains the deployed application

### GitLab

The GitLab instance is deployed using Helm and is accessible at http://localhost:8081.
- Username: root
- Password: Retrieved via `make get-gitlab-details`

### ArgoCD

ArgoCD is deployed in the cluster and configured to watch the GitLab repository.
- URL: Accessible via port forwarding on port 8181
- Username: admin
- Password: Retrieved via `make get-argocd-details`

### Application Deployment

The application source code is:
1. Cloned from a GitHub repository
2. Pushed to the internal GitLab instance
3. Automatically deployed by ArgoCD in the `dev` namespace

## GitOps Workflow

This project implements a GitOps workflow:
1. Code is pushed to the GitLab repository
2. ArgoCD detects changes in the repository
3. ArgoCD automatically applies the changes to the Kubernetes cluster
4. The application is updated in the `dev` namespace

## Troubleshooting

If port forwarding stops working:
```bash
make gitlab-stop-forward
make gitlab-forward
```

Or for ArgoCD:
```bash
make argocd-stop-forward
make argocd-forward
```

If you need to completely restart:
```bash
make re
```
