# s36: HPA — Solution

## Diagnosis

HPA exists but has no metrics configured. Check:

```bash
kubectl get hpa -n hpa-test
kubectl describe hpa -n hpa-test app-hpa
```

Expected: HPA shows "Metrics: unknown" or empty metrics list. Without metrics, HPA can't make scaling decisions.

## Fix

Add metrics to HPA. Patch to add CPU metric:

```bash
kubectl patch hpa -n hpa-test app-hpa -p '{"spec":{"metrics":[{"type":"Resource","resource":{"name":"cpu","target":{"type":"Utilization","averageUtilization":80}}}]}}'
```

Or recreate HPA with autoscale command that includes metrics:

```bash
kubectl delete hpa -n hpa-test app-hpa
kubectl autoscale deployment -n hpa-test app --min=1 --max=3 --cpu-percent=80
```

## Why

HPA needs metrics (CPU, memory, custom) to determine when to scale. Without metrics, HPA deployment remains at static replicas and ignores scale targets.
