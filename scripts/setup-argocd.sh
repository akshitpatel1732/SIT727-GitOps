#!/bin/bash
echo "Creating ArgoCD namespace and installing operator..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Exposing ArgoCD via Azure LoadBalancer..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

echo "Waiting for ArgoCD Server to become ready (this may take 1-2 minutes)..."
kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=300s

echo "Applying GitOps Application Configuration..."
kubectl apply -f argocd-config/netbox-application.yaml

echo "Fetching ArgoCD Access Credentials..."
ARGOCD_IP=""
while [ -z "$ARGOCD_IP" ] || [ "$ARGOCD_IP" == "pending" ]; do
  ARGOCD_IP=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
  if [ -z "$ARGOCD_IP" ]; then
    echo "Waiting for Azure to assign ArgoCD Public IP..."
    sleep 5
  fi
done

ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "ArgoCD setup complete. It is now watching the Git repository!"
echo "🌐 ArgoCD UI: https://$ARGOCD_IP (Accept self-signed cert)"
echo "👤 Username:  admin"
echo "🔑 Password:  $ARGOCD_PASS"