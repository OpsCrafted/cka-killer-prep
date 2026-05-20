# s34: Pod Affinity/Taints — Solution

## Diagnosis

Pod is Pending. Check node taints and pod status:

```bash
kubectl get nodes
kubectl describe node <node-name>
kubectl describe pod affinity-pod
```

Expected: nodes have taint `reserved=true:NoSchedule`. Pod cannot schedule because it lacks matching toleration.

## Fix

Add toleration to pod to tolerate the taint:

```bash
kubectl patch pod affinity-pod -p '{"spec":{"tolerations":[{"key":"reserved","operator":"Equal","value":"true","effect":"NoSchedule"}]}}'
```

Or delete and recreate pod with toleration in manifest.

## Why

Taints on nodes repel pods unless pod has matching toleration. Tolerations permit pods to schedule on tainted nodes.
