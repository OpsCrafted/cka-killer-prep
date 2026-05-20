# s27: DNS Debugging — Solution

## Diagnosis

Service exists but has no endpoints (DNS can resolve name but no backend):

```bash
kubectl get svc -n dns-test
kubectl get endpoints -n dns-test
kubectl get pods -n dns-test --show-labels
```

Expected: Service selector doesn't match pod labels, so no endpoints.

## Fix

Patch Service selector to match backend pod labels:

```bash
kubectl patch service -n dns-test test-svc -p '{"spec":{"selector":{"app":"test-backend"}}}'
```

Or recreate Service with correct selector:

```bash
kubectl delete svc -n dns-test test-svc
kubectl expose deployment -n dns-test test-backend --name=test-svc --port=80 --target-port=80
```

## Why

Service uses selector to find backing pods. Wrong selector = no endpoints = DNS resolves but traffic fails. Endpoint discovery is key to service DNS working.
