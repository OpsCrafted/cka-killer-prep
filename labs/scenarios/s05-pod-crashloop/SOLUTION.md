# s05: Pod Stuck in CrashLoopBackOff — Solution

## Diagnosis Path

Pod crashes repeatedly because a required ConfigMap is missing.

**Step 1:** Check pod status
```bash
kubectl describe pod <pod-name>
```

**Step 2:** Check previous logs
```bash
kubectl logs <pod-name> --previous
# Shows missing file error
```

**Step 3:** Identify missing ConfigMap
```bash
kubectl get configmaps
# app-config doesn't exist
```

**Step 4:** Create ConfigMap
```bash
kubectl create configmap app-config --from-literal=app.conf="app configuration"
```

**Step 5:** Verify pod recovers
```bash
kubectl get pods
# Pod transitions to Running
```

## Commands Used

```bash
kubectl describe pod <name>
kubectl logs <name> --previous
kubectl get configmaps
kubectl create configmap app-config --from-literal=app.conf="config"
kubectl get pods
```

## Why This Fix Works

Pod startup fails without ConfigMap. Creating it allows the mount to succeed and app to start normally.

## Common Wrong Fixes

- **Restarting pod** — Crashes again if ConfigMap still missing.
- **Changing restart policy** — Doesn't address root cause.
- **Wrong ConfigMap name** — Must match deployment volumes spec.
