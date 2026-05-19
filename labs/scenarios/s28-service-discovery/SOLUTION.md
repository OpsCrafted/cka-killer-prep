# s28: Service Discovery — Solution

## Diagnosis

```bash
kubectl get svc
kubectl get endpoints
```

## Fix

**Ensure pods have matching labels:**
```bash
kubectl label pod <pod> app=backend
```

**Verify endpoints:**
```bash
kubectl get endpoints <svc>
```

## Why

Endpoints controller matches service selectors to pod labels. No match = no endpoints.
