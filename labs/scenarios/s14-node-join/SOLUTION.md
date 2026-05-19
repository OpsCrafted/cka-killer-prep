# s14: Node Join — Solution

## Diagnosis

```bash
kubectl get nodes
```

## Fix

```bash
kubectl label node <node> node-role.kubernetes.io/worker=
```

## Why

Worker label identifies node role.
