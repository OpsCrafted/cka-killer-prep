#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Multi-tenancy RBAC
kubectl get namespace tenant-a 2>/dev/null || { echo "✗ FAILED: Namespace not found"; exit 1; }
kubectl get serviceaccount tenant-a-admin -n tenant-a 2>/dev/null || { echo "✗ FAILED: ServiceAccount not found"; exit 1; }
echo "✓ PASSED: Multi-tenancy RBAC configured"
exit 0
