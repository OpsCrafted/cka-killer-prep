#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Check if CRD is registered
if ! kubectl get crd bookings.travel.example.com &>/dev/null; then
  echo "✗ FAILED: Booking CRD not registered"
  exit 1
fi

# Check if we can list bookings (proves CRD is active)
if ! kubectl get bookings &>/dev/null; then
  echo "✗ FAILED: Cannot list bookings (CRD not fully active)"
  exit 1
fi

echo "✓ PASSED: Custom API (CRD) successfully deployed"
echo "  - CRD registered: bookings.travel.example.com"
echo "  - Can list bookings: kubectl get bookings"
exit 0
