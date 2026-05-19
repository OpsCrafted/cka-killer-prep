# s35: Priority & Preemption — Solution

## Diagnosis

```bash
kubectl get priorityclass
```

## Fix

**Create PriorityClass:**
```bash
kubectl apply -f - << 'PCEOF'
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: critical
value: 1000
globalDefault: false
description: "Critical workloads"
PCEOF
```

**Use in pod:**
```bash
kubectl patch pod <name> -p '{"spec":{"priorityClassName":"critical"}}'
```

## Why

High priority pods preempt low priority ones when resources scarce.
