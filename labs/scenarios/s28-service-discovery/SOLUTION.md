# s28: Service Discovery — Solution

## Diagnosis

Check service and endpoints:
```bash
kubectl get service app -n svc-test
kubectl get endpoints app -n svc-test
# No addresses listed (service has no backends)
```

Check pod labels vs service selector:
```bash
kubectl get pod -n svc-test --show-labels
# Pods have: app=app
kubectl get service app -n svc-test -o jsonpath='{.spec.selector}'
# Service selector: tier=backend (MISMATCH!)
```

## Fix

Option 1: Label pods to match service selector:
```bash
kubectl label pod -l app=app -n svc-test tier=backend
# Now service will discover pods
```

Option 2: Patch service selector to match deployment:
```bash
kubectl patch service app -n svc-test -p '{"spec":{"selector":{"app":"app"}}}'
```

Verify endpoints now exist:
```bash
kubectl get endpoints app -n svc-test
# Should show pod IPs in ENDPOINTS column
```

## Why

Endpoints controller automatically discovers pods matching service selector labels. Wrong selector = no endpoints discovered = no traffic routed.

## Key Concept

Service discovery works by:
1. Service defines selector labels
2. Endpoints controller finds pods with matching labels
3. Service uses endpoints for traffic routing
