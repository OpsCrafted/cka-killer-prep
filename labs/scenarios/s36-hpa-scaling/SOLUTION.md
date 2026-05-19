# s36: HPA — Solution

## Diagnosis

```bash
kubectl get hpa
kubectl describe hpa <name>
```

## Fix

**Create HPA:**
```bash
kubectl autoscale deployment <name> --min=2 --max=10 --cpu-percent=80
```

## Why

HPA automatically scales replicas based on CPU metrics.
