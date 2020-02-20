#!/bin/sh -e

# Publishing on local 80 and 443, but you can change this to 8080:80 and 8443:443 
k3d create --publish 80:80 --publish 443:443 

sleep 5 # wait for kubeconfig to become available
export KUBECONFIG=$(k3d get-kubeconfig)

# Create the namespace for hobbyfarm to be installed into
kubectl create namespace hobbyfarm

TFCERT=1
while [ $TFCERT -ne 0 ]; do
  echo "Waiting for traefik-default-cert to be created..."
  sleep 5
  kubectl -n kube-system get secret traefik-default-cert && TFCERT=0 || TFCERT=$?
done

# Delete the existing cert
echo "Deleting existing traefik-default-cert..."
kubectl -n kube-system delete secret traefik-default-cert

# substitute our own
echo "Creating new traefik-default-cert..."
kubectl -n kube-system create secret tls traefik-default-cert --cert=cert.pem --key=key.pem

# redeploy the traefik pod if it exists
echo "Redeploying traefik..."
kubectl -n kube-system patch deployment traefik -p "{\"spec\": {\"template\": {\"metadata\": { \"labels\": {  \"redeploy\": \"$(date +%s)\"}}}}}"

echo "Installing HobbyFarm chart..."
helm install hf charts/hobbyfarm --namespace hobbyfarm --values values-ignored.yaml --wait
