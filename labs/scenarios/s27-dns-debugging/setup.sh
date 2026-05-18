#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# DNS Service
kubectl create namespace dns-test 2>/dev/null || true
kubectl create service clusterip test-svc --tcp=80:80 -n dns-test 2>/dev/null || true
echo "✓ Scenario setup complete: DNS service created"

echo "✓ Scenario setup complete"
