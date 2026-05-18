#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check CoreDNS pods are Running
COREDNS_RUNNING=$(kubectl get pods -n kube-system -l k8s-app=kube-dns -o jsonpath='{.items[*].status.phase}' | grep -o "Running" | wc -l)

if [ "$COREDNS_RUNNING" -lt 1 ]; then
  echo "✗ FAILED: CoreDNS pod not Running"
  kubectl get pods -n kube-system -l k8s-app=kube-dns
  exit 1
fi

# Check DNS works from test pod
TEST_POD=$(kubectl get pod -l app=test-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$TEST_POD" ]; then
  echo "✗ FAILED: test-app pod not found"
  exit 1
fi

if kubectl exec "$TEST_POD" -- nslookup kubernetes.default &>/dev/null; then
  echo "✓ PASSED: DNS working"
  exit 0
else
  echo "✗ FAILED: DNS not resolving"
  exit 1
fi
