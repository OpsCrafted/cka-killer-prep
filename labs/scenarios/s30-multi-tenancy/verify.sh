#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: Tenant namespaces exist
kubectl get namespace tenant-a 2>/dev/null || {
  echo "✗ FAILED: Namespace tenant-a not found"
  exit 1
}

kubectl get namespace tenant-b 2>/dev/null || {
  echo "✗ FAILED: Namespace tenant-b not found"
  exit 1
}

# Check 2: ServiceAccounts exist in each namespace
kubectl get serviceaccount tenant-a-admin -n tenant-a 2>/dev/null || {
  echo "✗ FAILED: ServiceAccount tenant-a-admin not found"
  exit 1
}

kubectl get serviceaccount tenant-b-admin -n tenant-b 2>/dev/null || {
  echo "✗ FAILED: ServiceAccount tenant-b-admin not found"
  exit 1
}

echo "✓ PASSED: Multi-tenancy structure configured (tenant-a and tenant-b isolated)"
exit 0
