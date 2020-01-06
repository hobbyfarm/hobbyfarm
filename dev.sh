#!/bin/sh -ex
cd $(dirname $0)

k3d create --workers 3 --wait 0 || true
export KUBECONFIG=$(k3d get-kubeconfig)

kubectl create ns hobbyfarm || true

helm upgrade --install hf charts/hobbyfarm --namespace hobbyfarm --values charts/hobbyfarm/values.yaml --wait

# this can't be executed until all pods attached to services are running
sudo -E kubefwd services -n hobbyfarm
