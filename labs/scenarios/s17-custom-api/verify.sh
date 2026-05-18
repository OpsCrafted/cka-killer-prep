#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
# CRD not applied yet - this is the challenge
kubectl get crd bookings.example.com &>/dev/null || { echo "✗ FAILED: CRD not registered"; exit 1; }
echo "✓ PASSED: CRD successfully registered"
exit 0
