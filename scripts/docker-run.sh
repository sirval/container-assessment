#!/bin/bash

set -e

echo "Starting MuchToDo using Docker Compose..."

docker compose up --build -d

echo "Docker Compose started successfully."
echo ""
echo "Check running containers:"
echo "docker compose ps"
echo ""
echo "Test the application:"
echo "curl http://localhost:8080/health"
echo "curl http://localhost:8080/ping"