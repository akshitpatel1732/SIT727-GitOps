#!/bin/bash
echo "Initiating teardown of Azure resources..."
echo "Resource Group: NetBox-HD-Project"

# Delete the resource group and everything inside it without waiting for completion
az group delete --name NetBox-HD-Project --yes --no-wait

echo "Teardown initiated. Azure is deleting the resources in the background."
echo "You will no longer be billed for this cluster."