#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Delete the CRD and all Booking instances
kubectl delete crd bookings.travel.example.com 2>/dev/null || true
rm -rf /tmp/crd-scenario 2>/dev/null || true

echo "✓ Scenario reset"
