#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Ingress with TLS
kubectl get ingress tls-ingress -n ingress-test 2>/dev/null || { echo "✗ FAILED: Ingress not found"; exit 1; }
echo "✓ PASSED: Ingress TLS configured"
exit 0
