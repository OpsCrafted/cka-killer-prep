#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: PVC exists and is bound
PVC_STATUS=$(kubectl get pvc app-claim -n storage-test -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PVC_STATUS" != "Bound" ]]; then
  echo "✗ FAILED: PVC not bound (current: $PVC_STATUS)"
  exit 1
fi

# Check 2: Verify PVC is bound to a PV
BOUND_PV=$(kubectl get pvc app-claim -n storage-test -o jsonpath='{.spec.volumeName}' 2>/dev/null)
if [[ -z "$BOUND_PV" ]]; then
  echo "✗ FAILED: PVC bound but no volume name assigned"
  exit 1
fi

# Check 3: Verify PV exists and is bound
PV_STATUS=$(kubectl get pv "$BOUND_PV" -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PV_STATUS" != "Bound" ]]; then
  echo "✗ FAILED: PV $BOUND_PV not bound (status: $PV_STATUS)"
  exit 1
fi

echo "✓ PASSED: PVC successfully bound to PV ($BOUND_PV)"
exit 0
