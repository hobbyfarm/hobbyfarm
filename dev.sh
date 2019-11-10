#!/bin/sh -e

k3d create
sleep 5 # wait for kubeconfig to become available
export KUBECONFIG=$(k3d get-kubeconfig)

kubectl apply -f - << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF
helm init --service-account tiller --history-max 200 --wait

helm install --name hf --namespace hobbyfarm -t values-ignored.yaml .

# this can't be executed until all pods attached to services are running
#sudo -E kubefwd services -n hobbyfarm -n ranchervm-system
