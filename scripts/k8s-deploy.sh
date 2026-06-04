#!/bin/bash

set -e

CLUSTER_NAME="muchtodo-cluster"
IMAGE_NAME="muchtodo-backend:latest"

echo "Building Docker image..."
docker build -t $IMAGE_NAME .

echo "Checking if Kind cluster exists..."

if /c/kind/kind.exe get clusters | grep -q "$CLUSTER_NAME"; then
  echo "Kind cluster '$CLUSTER_NAME' already exists."
else
  echo "Creating Kind cluster '$CLUSTER_NAME'..."
  /c/kind/kind.exe create cluster --config kind-config.yaml
fi

echo "Loading Docker image into Kind..."
/c/kind/kind.exe load docker-image $IMAGE_NAME --name $CLUSTER_NAME

echo "Deploying Kubernetes resources..."

kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/mongodb/
kubectl apply -f kubernetes/backend/

echo "Kubernetes deployment completed."
echo ""
echo "Check pods:"
echo "kubectl get pods -n muchtodo"
echo ""
echo "Check services:"
echo "kubectl get svc -n muchtodo"
echo ""
echo "Test application through NodePort:"
echo "curl http://localhost:8081/health"
echo "curl http://localhost:8081/ping"