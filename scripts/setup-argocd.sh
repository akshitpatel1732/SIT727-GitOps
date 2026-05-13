#!/bin/bash
echo "Creating ArgoCD namespace and installing operator..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD Server to become ready (this may take 1-2 minutes)..."
kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=300s

echo "Applying GitOps Application Configuration..."
kubectl apply -f argocd-config/netbox-application.yaml

echo "ArgoCD setup complete. It is now watching the Git repository!"