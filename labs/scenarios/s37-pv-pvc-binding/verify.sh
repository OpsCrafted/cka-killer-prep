#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check PVC is bound
STATUS=$(kubectl get pvc app-claim -n storage-test -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$STATUS" != "Bound" ]]; then
  echo "✗ FAILED: PVC not bound (current: $STATUS)"
  exit 1
fi

# Check PV is bound
PV=$(kubectl get pvc app-claim -n storage-test -o jsonpath='{.spec.volumeName}' 2>/dev/null)
PV_STATUS=$(kubectl get pv "$PV" -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PV_STATUS" != "Bound" ]]; then
  echo "✗ FAILED: PV not bound (current: $PV_STATUS)"
  exit 1
fi

echo "✓ PASSED: PVC bound to PV"
exit 0
