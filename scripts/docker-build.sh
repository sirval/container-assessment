#!/bin/bash

set -e

IMAGE_NAME="muchtodo-backend:latest"

echo "Building Docker image: $IMAGE_NAME"

docker build -t $IMAGE_NAME .

echo "Docker image built successfully."