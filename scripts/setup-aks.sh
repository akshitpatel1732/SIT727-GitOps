#!/bin/bash
# Define Variables
RESOURCE_GROUP="NetBox-HD-Project"
CLUSTER_NAME="netbox-aks-cluster"
LOCATION="australiaeast"

# Create the Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create the AKS Cluster
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 2 \
  --node-vm-size Standard_B2s \
  --generate-ssh-keys

# Get kubectl credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing

# Create Namespaces
kubectl create namespace argocd
kubectl create namespace netbox