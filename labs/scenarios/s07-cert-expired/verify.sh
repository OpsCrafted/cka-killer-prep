#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check API server is responsive
if ! kubectl get nodes &>/dev/null; then
  echo "✗ FAILED: API server not responding"
  exit 1
fi

# Check nodes are Ready
READY_COUNT=$(kubectl get nodes | grep "Ready" | wc -l)
TOTAL_COUNT=$(kubectl get nodes | tail -n +2 | wc -l)

if [ "$READY_COUNT" -ne "$TOTAL_COUNT" ]; then
  echo "✗ FAILED: Not all nodes Ready"
  exit 1
fi

# Check control plane certs are not expired
docker exec "$CLUSTER_NAME-control-plane" kubeadm certs check-expiration 2>/dev/null | grep -i "ok" >/dev/null

if [ $? -eq 0 ]; then
  echo "✓ PASSED: Certificates valid"
  exit 0
else
  echo "✗ FAILED: Certificate check failed"
  exit 1
fi
