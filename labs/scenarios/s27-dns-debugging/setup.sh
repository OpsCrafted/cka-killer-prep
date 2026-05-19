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

# Wait for pod to be ready
for i in {1..30}; do
  READY=$(kubectl get deployment test-backend -n dns-test -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo 0)
  [[ "$READY" -gt 0 ]] && break
  sleep 1
done

# Expose deployment as service (auto-selects correct pods)
kubectl expose deployment test-backend --name=test-svc --port=80 --target-port=80 -n dns-test 2>/dev/null || true

# Wait for endpoints to populate
for i in {1..10}; do
  ENDPOINT_COUNT=$(kubectl get endpoints test-svc -n dns-test -o jsonpath='{.subsets[0].addresses[*].ip}' 2>/dev/null | wc -w)
  [[ $ENDPOINT_COUNT -gt 0 ]] && break
  sleep 1
done

echo "✓ Scenario setup complete: DNS service with backend pods created"
