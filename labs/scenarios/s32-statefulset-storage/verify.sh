#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: StatefulSet exists
kubectl get statefulset db -n stateful-test &>/dev/null || {
  echo "✗ FAILED: StatefulSet db not found"
  exit 1
}

# Check 2: All pods have ordinal names (db-0, db-1, db-2)
for ordinal in 0 1 2; do
  kubectl get pod db-$ordinal -n stateful-test &>/dev/null || {
    echo "✗ FAILED: Pod db-$ordinal not found"
    exit 1
  }
done

# Check 3: Pods are Running
for ordinal in 0 1 2; do
  status=$(kubectl get pod db-$ordinal -n stateful-test -o jsonpath='{.status.phase}')
  if [[ "$status" != "Running" ]]; then
    echo "✗ FAILED: Pod db-$ordinal not Running (status: $status)"
    exit 1
  fi
done

# Check 4: Headless service exists
kubectl get service db -n stateful-test &>/dev/null || {
  echo "✗ FAILED: Headless service db not found"
  exit 1
}

# Check 5: Service is headless (clusterIP is None)
clusterip=$(kubectl get service db -n stateful-test -o jsonpath='{.spec.clusterIP}')
if [[ "$clusterip" != "None" ]]; then
  echo "✗ FAILED: Service is not headless (clusterIP: $clusterip)"
  exit 1
fi

echo "✓ PASSED: StatefulSet with persistent identity working"
exit 0
