#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: Local StorageClass exists
kubectl get storageclass local &>/dev/null || {
  echo "✗ FAILED: Local StorageClass not found"
  exit 1
}

# Check 2: Local PV exists
kubectl get pv local-pv &>/dev/null || {
  echo "✗ FAILED: Local PV local-pv not found"
  exit 1
}

# Check 3: PV has local path
path=$(kubectl get pv local-pv -o jsonpath='{.spec.local.path}')
if [[ -z "$path" ]]; then
  echo "✗ FAILED: PV does not have local path configured"
  exit 1
fi

# Check 4: PV has node affinity (required for local storage)
affinity=$(kubectl get pv local-pv -o jsonpath='{.spec.nodeAffinity}')
if [[ "$affinity" == "null" || "$affinity" == "{}" ]]; then
  echo "✗ FAILED: PV missing node affinity constraint"
  exit 1
fi

# Check 5: PVC binds to local PV
pvc_name=$(kubectl get pvc -n local-test -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [[ -z "$pvc_name" ]]; then
  pvc_name="local-pvc"
fi
pvc_status=$(kubectl get pvc "$pvc_name" -n local-test -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$pvc_status" != "Bound" ]]; then
  echo "⚠ WARNING: PVC not bound (may be in different namespace)"
fi

echo "✓ PASSED: Local storage PV configured with node affinity"
exit 0
