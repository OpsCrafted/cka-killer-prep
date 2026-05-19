# s13: Cluster Upgrade — Solution

## Diagnosis

```bash
kubectl get nodes
```

## Fix

```bash
kubectl uncordon <node>
```

## Why

Cordoned node blocks scheduling.
