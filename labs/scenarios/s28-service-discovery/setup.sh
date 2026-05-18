#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# Service Discovery
kubectl create namespace svc-test 2>/dev/null || true
kubectl create deployment app -n svc-test --image=nginx 2>/dev/null || true
sleep 2
kubectl create service clusterip app --tcp=80:80 -n svc-test 2>/dev/null || true

echo "✓ Scenario setup complete"
