#!/bin/bash

# Install kubectl
echo "=========================================="
echo "Installing kubectl"
echo "=========================================="
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# Install minikube
echo "=========================================="
echo "Installing minikube"
echo "=========================================="
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start minikube
echo "=========================================="
echo "Starting minikube"
echo "=========================================="
minikube start

# Install nginx ingress controller
echo "=========================================="
echo "Installing nginx ingress controller"
echo "=========================================="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.46.0/deploy/static/provider/cloud/deploy.yaml
