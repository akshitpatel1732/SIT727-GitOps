# NetBox GitOps Deployment on Azure Kubernetes Service (AKS)

This repository contains the infrastructure-as-code and GitOps deployment manifests for hosting NetBox on a managed Azure Kubernetes Service (AKS) cluster. It demonstrates advanced cloud-native orchestration, automated continuous delivery via ArgoCD, and dynamic elasticity using the Horizontal Pod Autoscaler (HPA).

## Architecture

* **Cloud Provider:** Microsoft Azure (AKS)
* **Application:** NetBox (Django/Python)
* **Database / Cache:** PostgreSQL 18 & Redis 8 (Deployed as StatefulSets with Azure `managed-csi` persistent storage)
* **Continuous Delivery:** ArgoCD (GitOps methodology)
* **Testing:** Native Bash/cURL (Zero-dependency simulated load to demonstrate horizontal scaling)

## Repository Structure

* `/manifests`: The declarative Kubernetes YAML files. **This directory is actively monitored by ArgoCD.** Any changes pushed here are automatically reconciled in the cluster.
* `/argocd-config`: The core ArgoCD `Application` custom resource definition.
* `/scripts`: Reproducible bash scripts to completely provision, configure, and test the infrastructure from scratch.

## Deployment Instructions

This environment is designed to be fully reproducible in four steps. Ensure you are logged into the Azure CLI (`az login`) before beginning.

### Step 1: Provision Infrastructure
This provisions the AKS resource group, the cluster nodes, and fetches the `kubectl` credentials.
```bash
chmod +x scripts/*.sh
./scripts/setup-aks.sh
```

### Step 2: Inject Secrets
To adhere to security best practices, sensitive credentials are not stored in version control.
1. Copy `manifests/netbox-secrets.yaml.template` to `manifests/netbox-secrets.yaml`.
2. Populate the file with secure passwords.
3. Run the injection script:
```bash
./scripts/setup-secrets.sh
```

### Step 3: Install GitOps Controller
This installs ArgoCD and applies the configuration pointing to this repository. Once executed, ArgoCD will autonomously spin up the NetBox application, databases, and persistent storage.
```bash
./scripts/setup-argocd.sh
```

### Step 4: Demonstrate Elasticity (Load Testing)
To verify the Horizontal Pod Autoscaler (HPA) behaves correctly under user traffic, run the automated load testing script. This script dynamically extracts the Azure LoadBalancer IP and executes a concurrent cURL loop to spike CPU utilization.
```bash
# Monitor the scaling in a separate terminal: kubectl get hpa -n netbox -w
./scripts/run-loadtest.sh
```

### Step 5: Teardown Infrastructure
To prevent ongoing cloud billing, the infrastructure can be completely destroyed with a single command. This will asynchronously delete the AKS cluster, the resource group, and all dynamically provisioned managed disks.
```bash
./scripts/teardown-aks.sh
```