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
if ! kubectl get nodes -l node-role.kubernetes.io/control-plane --no-headers | grep -q "Ready"; then
  echo "✗ FAILED: Control plane node not Ready"
  exit 1
fi

# Check 3: All worker nodes are Ready
worker_count=$(kubectl get nodes -l node-role.kubernetes.io/worker --no-headers 2>/dev/null | wc -l | tr -d ' ')
ready_count=$(kubectl get nodes -l node-role.kubernetes.io/worker --no-headers 2>/dev/null | grep -c " Ready " || true)
if [ "$worker_count" -gt 0 ] && [ "$worker_count" -ne "$ready_count" ]; then
  echo "✗ FAILED: Not all workers Ready ($ready_count/$worker_count)"
  exit 1
fi

# Check 4: kube-apiserver manifest has correct etcd port
etcd_port=$(docker exec "${CLUSTER_NAME}-control-plane" \
  grep -o 'etcd-servers=https://127.0.0.1:[0-9]*' /etc/kubernetes/manifests/kube-apiserver.yaml \
  | grep -o '[0-9]*$')
if [ "$etcd_port" != "2379" ]; then
  echo "✗ FAILED: kube-apiserver still has wrong etcd port ($etcd_port, want 2379)"
  exit 1
fi

# Check 5: demo-app pods are Running
running=$(kubectl get pods -l app=demo-app --no-headers 2>/dev/null | grep -c "Running" || true)
if [ "$running" -lt 2 ]; then
  echo "✗ FAILED: demo-app pods not Running ($running/2)"
  exit 1
fi

echo "✓ PASSED: API server healthy, etcd config correct, all nodes Ready"
exit 0
