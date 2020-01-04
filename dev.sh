#!/bin/sh -e

k3d create
sleep 7 # wait for kubeconfig to become available
export KUBECONFIG=$(k3d get-kubeconfig)

kubectl create ns hobbyfarm

helm install hf charts/hobbyfarm --namespace hobbyfarm --values charts/hobbyfarm/values.yaml --wait

# this can't be executed until all pods attached to services are running
sudo -E kubefwd services -n hobbyfarm
