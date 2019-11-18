#!/bin/sh -e

k3d create
sleep 5 # wait for kubeconfig to become available
export KUBECONFIG=$(k3d get-kubeconfig)

helm install hf . --namespace hobbyfarm -f values-ignored.yaml --wait

# this can't be executed until all pods attached to services are running
sudo -E kubefwd services -n hobbyfarm
