#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# Multi-tenancy RBAC
kubectl create namespace tenant-a 2>/dev/null || true
kubectl create namespace tenant-b 2>/dev/null || true
kubectl create serviceaccount tenant-a-admin -n tenant-a 2>/dev/null || true
kubectl create serviceaccount tenant-b-admin -n tenant-b 2>/dev/null || true

echo "✓ Scenario setup complete"
