#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: Namespace exists
if ! kubectl get namespace critical-app &>/dev/null; then
  echo "✗ FAILED: Namespace critical-app not found"
  exit 1
fi

# Check 2: Deployment exists (proves more than just namespace was restored)
if ! kubectl get deployment critical-service -n critical-app &>/dev/null; then
  echo "✗ FAILED: Deployment critical-service not found"
  exit 1
fi

# Check 3: ConfigMap with original data exists (proves etcd restore was used)
if ! kubectl get configmap critical-config -n critical-app &>/dev/null; then
  echo "✗ FAILED: ConfigMap critical-config not found - appears to be manual recreation"
  exit 1
fi

# Check 4: ConfigMap has expected data
DB=$(kubectl get configmap critical-config -n critical-app -o jsonpath='{.data.database}')
REPLICAS=$(kubectl get configmap critical-config -n critical-app -o jsonpath='{.data.replicas}')

if [[ "$DB" != "production-db" ]] || [[ "$REPLICAS" != "3" ]]; then
  echo "✗ FAILED: ConfigMap data does not match original (db=$DB, replicas=$REPLICAS)"
  exit 1
fi

echo "✓ PASSED: Namespace and resources restored from backup"
echo "  - Namespace critical-app restored"
echo "  - Deployment critical-service present"
echo "  - ConfigMap critical-config with original data"
exit 0
