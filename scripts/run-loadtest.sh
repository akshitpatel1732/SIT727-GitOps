#!/bin/bash

# Trap CTRL+C to cleanly stop the background curl loops
trap 'echo -e "\nStopping load test..."; kill $(jobs -p) 2>/dev/null; exit' SIGINT SIGTERM

echo "Fetching External IP from the NetBox LoadBalancer..."

# Loop until the External IP is assigned by Azure
EXTERNAL_IP=""
while [ -z "$EXTERNAL_IP" ] || [ "$EXTERNAL_IP" == "pending" ]; do
  EXTERNAL_IP=$(kubectl get svc netbox-web -n netbox -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
  if [ -z "$EXTERNAL_IP" ]; then
    echo "IP is still pending. Waiting 5 seconds..."
    sleep 5
  fi
done

echo "Target IP Acquired: $EXTERNAL_IP"
echo "Starting native bash load test to trigger Horizontal Pod Autoscaling..."
echo "Sending continuous traffic. Press [CTRL+C] to stop."
echo "------------------------------------------------------"
echo "Open a new terminal and run: kubectl get hpa -n netbox -w"
echo "------------------------------------------------------"

# Spin up 20 concurrent background processes hammering the endpoint
for i in {1..20}; do
  while true; do
    curl -s -o /dev/null "http://$EXTERNAL_IP/"
  done &
done

# Wait indefinitely until the user presses CTRL+C
wait