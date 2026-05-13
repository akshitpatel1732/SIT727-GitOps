#!/bin/bash
# Manually inject secrets into the cluster since they are not stored in git
SECRETS_FILE="./manifests/netbox-secrets.yaml"
TEMPLATE_FILE="./manifests/netbox-secrets.yaml.template"

# Check if the secret file has been created from the template
if [ ! -f "$SECRETS_FILE" ]; then
    echo "Error: $SECRETS_FILE not found."
    echo "Copy $TEMPLATE_FILE to $SECRETS_FILE and fill in values before running."
    exit 1
fi

# Apply the secret to the netbox namespace
kubectl apply -f "$SECRETS_FILE" -n netbox