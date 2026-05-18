#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Wait for API
for i in {1..30}; do
  kubectl get nodes &>/dev/null && break
  sleep 1
done

# Create a CRD definition file but DON'T apply it yet
# This is the scenario: the CRD is ready but not deployed
mkdir -p /tmp/crd-scenario

cat > /tmp/crd-scenario/booking-crd.yaml << 'CRD'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: bookings.travel.example.com
spec:
  group: travel.example.com
  names:
    kind: Booking
    plural: bookings
    singular: booking
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              destination:
                type: string
              duration:
                type: integer
CRD

# Display what needs to be done
echo "CRD definition ready at /tmp/crd-scenario/booking-crd.yaml"
echo "Task: Apply the CustomResourceDefinition to the cluster"
echo "✓ Scenario setup complete: CRD needs to be applied"
