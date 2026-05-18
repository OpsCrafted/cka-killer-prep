#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: API server is responding
if ! kubectl get nodes &>/dev/null; then
  echo "✗ FAILED: API server not responding"
  exit 1
fi

# Check 2: Control plane is Ready
if ! kubectl get nodes -l node-role.kubernetes.io/control-plane | grep -q "Ready"; then
  echo "✗ FAILED: Control plane node not Ready"
  exit 1
fi

# Check 3: All worker nodes are Ready
worker_count=$(kubectl get nodes -l node-role.kubernetes.io/worker | tail -n +2 | wc -l)
ready_count=$(kubectl get nodes -l node-role.kubernetes.io/worker | grep "Ready" | wc -l)

if [ "$worker_count" -ne "$ready_count" ]; then
  echo "✗ FAILED: Not all workers Ready ($ready_count/$worker_count)"
  exit 1
fi

# Check 4: Deployment pods are Running
if ! kubectl get pods -l app=demo-app | grep -q "2/2.*Running"; then
  echo "✗ FAILED: Deployment pods not Running"
  exit 1
fi

echo "✓ PASSED: API server is healthy"
exit 0
