#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# DNS Service - create namespace and backend pods first
kubectl create namespace dns-test 2>/dev/null || true

# Create backend deployment
kubectl create deployment test-backend -n dns-test --image=nginx 2>/dev/null || true

# Wait for deployment to have ready replicas
timeout 60 kubectl rollout status deployment/test-backend -n dns-test 2>/dev/null || true

# Expose deployment as service (auto-selects correct pods)
kubectl expose deployment test-backend --name=test-svc --port=80 --target-port=80 -n dns-test 2>/dev/null || true

# Short wait for endpoints
sleep 2

echo "✓ Scenario setup complete: DNS service with backend pods created"
