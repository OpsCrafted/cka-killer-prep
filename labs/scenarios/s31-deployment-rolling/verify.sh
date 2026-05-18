#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

kubectl get deployment web-app -n rollout-test &>/dev/null || {
  echo "✗ FAILED: Deployment not found"
  exit 1
}

READY=$(kubectl get deployment web-app -n rollout-test -o jsonpath='{.status.readyReplicas}')
DESIRED=$(kubectl get deployment web-app -n rollout-test -o jsonpath='{.spec.replicas}')
if [[ "$READY" != "$DESIRED" ]]; then
  echo "✗ FAILED: Not all replicas ready ($READY/$DESIRED)"
  exit 1
fi

MAX_SURGE=$(kubectl get deployment web-app -n rollout-test -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}')
MAX_UNAVAIL=$(kubectl get deployment web-app -n rollout-test -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}')

if [[ "$MAX_SURGE" == "0" ]]; then
  echo "✗ FAILED: maxSurge is 0 (causes downtime during updates)"
  exit 1
fi

if [[ "$MAX_UNAVAIL" != "0" ]]; then
  echo "✗ FAILED: maxUnavailable should be 0 for zero-downtime (current: $MAX_UNAVAIL)"
  exit 1
fi

echo "✓ PASSED: Rolling update configured for zero-downtime"
exit 0
