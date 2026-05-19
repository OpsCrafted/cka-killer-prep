# s33: Resource Limits — Solution

## Diagnosis

```bash
kubectl describe pod <name>
```

## Fix

**Add resource limits:**
```bash
kubectl set resources deployment/<name> --limits=cpu=500m,memory=512Mi --requests=cpu=250m,memory=256Mi
```

**Or edit deployment:**
```bash
kubectl edit deployment <name>
# Add: resources: limits: cpu: 500m, memory: 512Mi
```

## Why

Limits prevent runaway usage. Requests guarantee resources.
