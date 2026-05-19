# s17: Custom API — Solution

## Diagnosis

```bash
kubectl get apiservices
kubectl api-resources
```

## Fix

**Register APIService:**
```bash
kubectl apply -f - <<'APIEOF'
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  name: v1.custom.example
spec:
  service:
    name: custom-api
    namespace: default
  group: custom.example
  version: v1
  groupPriorityMinimum: 1000
  versionPriority: 100
APIEOF
```

**Verify:**
```bash
kubectl api-resources | grep custom
```

## Why

APIService registers custom API group.
