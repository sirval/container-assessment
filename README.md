# MuchToDo Containerization and Kubernetes Deployment

## Project Overview

This project is part of the Month 2 DevOps assessment for containerizing and deploying the MuchToDo backend application.

The application is a Golang backend API that connects to MongoDB for data storage. The project includes a Docker setup for local development using Docker Compose and Kubernetes manifests for deployment to a local Kind cluster.

## Application Features

- Golang backend API
- MongoDB database
- Health check endpoint
- Basic API endpoint testing
- Dockerized backend service
- MongoDB persistence using Docker volume and Kubernetes PVC
- Kubernetes deployment using Kind
- NodePort service for local access
- Ingress manifest for HTTP routing

## Technologies Used

- Go
- Docker
- Docker Compose
- MongoDB
- Kubernetes
- Kind
- kubectl
- NGINX Ingress

## Project Structure

```text
container-assessment/
├── Server/
│   └── MuchToDo/
│       ├── cmd/
│       ├── docs/
│       ├── internal/
│       ├── go.mod
│       ├── go.sum
│       └── Makefile
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── kind-config.yaml
├── kubernetes/
│   ├── namespace.yaml
│   ├── mongodb/
│   │   ├── mongodb-secret.yaml
│   │   ├── mongodb-configmap.yaml
│   │   ├── mongodb-pvc.yaml
│   │   ├── mongodb-deployment.yaml
│   │   └── mongodb-service.yaml
│   ├── backend/
│   │   ├── backend-secret.yaml
│   │   ├── backend-configmap.yaml
│   │   ├── backend-deployment.yaml
│   │   └── backend-service.yaml
│   └── ingress.yaml
├── scripts/
│   ├── docker-build.sh
│   ├── docker-run.sh
│   ├── k8s-deploy.sh
│   └── k8s-cleanup.sh
├── evidence/
└── README.md
```

## Prerequisites

Before running this project, ensure the following tools are installed:

- Docker Desktop
- Docker Compose
- Kind
- kubectl
- Git Bash or any terminal

Verify installation:

```bash
docker version
docker compose version
/c/kind/kind.exe version
kubectl version --client
```

## Phase 1: Docker Setup

### 1. Build the Docker Image

From the project root, run:

```bash
docker build -t muchtodo-backend:latest .
```

Or use the provided script:

```bash
./scripts/docker-build.sh
```

### 2. Run the Application with Docker Compose

```bash
docker compose up --build -d
```

Or use:

```bash
./scripts/docker-run.sh
```

This starts:

- MongoDB container
- MuchToDo backend container

### 3. Verify Running Containers

```bash
docker compose ps
```

Expected result:

```text
muchtodo-mongodb   running
muchtodo-backend   running
```

### 4. Test the Application

Health check endpoint:

```bash
curl http://localhost:8080/health
```

Expected response:

```json
{"cache":"disabled","database":"ok"}
```

Ping endpoint:

```bash
curl http://localhost:8080/ping
```

Expected response:

```json
{"message":"pong"}
```

### 5. Stop Docker Compose

```bash
docker compose down
```

To remove the MongoDB volume as well:

```bash
docker compose down -v
```

## Phase 2: Kubernetes Deployment with Kind

### 1. Create Kind Cluster

The Kind cluster uses the configuration in `kind-config.yaml`.

```bash
/c/kind/kind.exe create cluster --config kind-config.yaml
```

Verify the cluster:

```bash
kubectl get nodes
```

Expected result:

```text
muchtodo-cluster-control-plane   Ready
```

### 2. Build and Load Docker Image into Kind

Kind does not automatically use local Docker images, so the backend image must be loaded into the Kind cluster.

```bash
docker build -t muchtodo-backend:latest .
/c/kind/kind.exe load docker-image muchtodo-backend:latest --name muchtodo-cluster
```

### 3. Deploy Kubernetes Resources

Apply the namespace:

```bash
kubectl apply -f kubernetes/namespace.yaml
```

Apply MongoDB resources:

```bash
kubectl apply -f kubernetes/mongodb/
```

Apply backend resources:

```bash
kubectl apply -f kubernetes/backend/
```

Or deploy everything using the script:

```bash
./scripts/k8s-deploy.sh
```

### 4. Verify Kubernetes Resources

Check pods:

```bash
kubectl get pods -n muchtodo
```

Expected result:

```text
mongodb-xxxxx    1/1   Running
backend-xxxxx    1/1   Running
backend-yyyyy    1/1   Running
```

Check services:

```bash
kubectl get svc -n muchtodo
```

Expected services:

```text
mongodb-service
backend-service
```

### 5. Access the Application Through NodePort

The backend service is exposed using NodePort `30080`.

The Kind cluster maps this to host port `8081`.

Test the health endpoint:

```bash
curl http://localhost:8081/health
```

Expected response:

```json
{"cache":"disabled","database":"ok"}
```

Test the ping endpoint:

```bash
curl http://localhost:8081/ping
```

Expected response:

```json
{"message":"pong"}
```

## Ingress

The project includes an ingress manifest:

```text
kubernetes/ingress.yaml
```

To use ingress, an ingress controller must be installed in the Kind cluster first.

Apply ingress:

```bash
kubectl apply -f kubernetes/ingress.yaml
```

Check ingress:

```bash
kubectl get ingress -n muchtodo
```

The configured host is:

```text
muchtodo.local
```

Add this to your hosts file if testing locally:

```text
127.0.0.1 muchtodo.local
```

Then test:

```bash
curl http://muchtodo.local/health
```

## Automation Scripts

The project includes scripts to simplify common tasks.

### Build Docker Image

```bash
./scripts/docker-build.sh
```

### Run Docker Compose

```bash
./scripts/docker-run.sh
```

### Deploy to Kubernetes

```bash
./scripts/k8s-deploy.sh
```

### Cleanup Kubernetes Resources

```bash
./scripts/k8s-cleanup.sh
```

## Kubernetes Cleanup

To remove the application resources from Kubernetes:

```bash
kubectl delete namespace muchtodo
```

Or use:

```bash
./scripts/k8s-cleanup.sh
```

To delete the Kind cluster completely:

```bash
/c/kind/kind.exe delete cluster --name muchtodo-cluster
```

## Evidence

Screenshots are stored in the `evidence/` folder.

Required evidence includes:

1. Docker image build completed successfully
2. Docker Compose containers running
3. Application responding through Docker Compose
4. Kind cluster created successfully
5. Kubernetes pods running
6. Kubernetes services created
7. Application responding through Kubernetes NodePort
8. Ingress resource created

Suggested evidence files:

```text
evidence/
├── 01-docker-build-success.png
├── 02-docker-compose-running.png
├── 03-docker-compose-health-response.png
├── 04-kind-cluster-created.png
├── 05-kubernetes-pods-running.png
├── 06-kubernetes-services.png
├── 07-nodeport-health-response.png
└── 08-kubernetes-ingress.png
```

## Notes

- The backend runs on port `8080`.
- MongoDB runs on port `27017`.
- In Docker Compose, the backend connects to MongoDB using the service name `mongodb`.
- In Kubernetes, the backend connects to MongoDB using the service name `mongodb-service`.
- The backend image is named `muchtodo-backend:latest`.
- The Kubernetes namespace used is `muchtodo`.