#!/bin/bash

set -e

echo "Deleting MuchToDo Kubernetes namespace..."

kubectl delete namespace muchtodo --ignore-not-found=true

echo "Kubernetes resources cleaned up successfully."