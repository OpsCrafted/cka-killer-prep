# s34: Pod Affinity/Taints — Solution

## Diagnosis

```bash
kubectl get nodes --show-labels
kubectl describe node <name>
```

## Fix

**Add nodeAffinity to deployment:**
```bash
kubectl patch deployment <name> -p '{"spec":{"template":{"spec":{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"disktype","operator":"In","values":["ssd"]}]}]}}}}}}}'
```

## Why

Affinity constrains scheduling by node labels.
