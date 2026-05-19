# s15: Runtime Switch — Solution

## Diagnosis

```bash
kubectl describe node <node>
```

## Fix

```bash
kubectl taint node <node> runtime:NoSchedule-
```

## Why

Removing taint allows scheduling.
