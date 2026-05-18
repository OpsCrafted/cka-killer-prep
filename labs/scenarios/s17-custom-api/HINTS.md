# Hints for s17: Custom API / CRD

## Problem
CustomResourceDefinition needs to be deployed to cluster.

## Step 1: Apply the CRD

The CRD definition is ready at /tmp/crd-scenario/booking-crd.yaml

```bash
kubectl apply -f /tmp/crd-scenario/booking-crd.yaml
```

## Step 2: Verify CRD is registered

```bash
kubectl get crd
kubectl get crd bookings.travel.example.com
```

## Step 3: Test the API

Once registered, you can create Booking resources:

```bash
kubectl get bookings
kubectl create bookings my-trip --dry-run=client -o yaml
```

## Key Concepts

- **CRD**: Extends Kubernetes API with custom resource types
- **Group**: API group (e.g., travel.example.com)
- **Version**: API version (e.g., v1)
- **Kind**: Resource type (e.g., Booking)

## Commands

```bash
kubectl get crd                           # List all CRDs
kubectl get crd <name>                    # Check specific CRD
kubectl describe crd <name>               # Details
kubectl apply -f <crd-file>               # Deploy CRD
kubectl delete crd <name>                 # Remove CRD
```
