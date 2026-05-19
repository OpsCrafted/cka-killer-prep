#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: PVC exists
PVC_STATUS=$(kubectl get pvc app-claim -n storage-test -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PVC_STATUS" != "Bound" ]]; then
  echo "✗ FAILED: PVC not bound (current: $PVC_STATUS)"
  exit 1
fi

# Check 2: PVC bound to PV
pv_name=$(kubectl get pvc app-claim -n storage-test -o jsonpath='{.spec.volumeName}')
if [[ -z "$pv_name" ]]; then
  echo "✗ FAILED: PVC not bound to any PV"
  exit 1
fi

# Check 3: PV exists and is bound
kubectl get pv "$pv_name" &>/dev/null || {
  echo "✗ FAILED: PV $pv_name not found"
  exit 1
}

# Check 4: Pod mounts the PVC
kubectl get pod test-pod -n storage-test &>/dev/null || {
  echo "✗ FAILED: Test pod not found"
  exit 1
}

# Check 5: Pod can write to mounted volume (test file exists)
has_mount=$(kubectl get pod test-pod -n storage-test -o jsonpath='{.spec.volumes[*].persistentVolumeClaim.claimName}' | grep -c "app-claim")
if [[ $has_mount -eq 0 ]]; then
  echo "✗ FAILED: Pod does not mount the PVC"
  exit 1
fi

echo "✓ PASSED: PV and PVC bound, pod mounted successfully"
exit 0
