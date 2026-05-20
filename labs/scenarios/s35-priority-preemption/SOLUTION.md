# s35: Priority & Preemption — Solution

## Diagnosis

High-priority pod is Pending due to resource contention with low-priority pod. Check pod statuses:

```bash
kubectl get pods -n priority-test
kubectl describe pod -n priority-test high-priority
kubectl describe pod -n priority-test low-priority
```

Expected: high-priority pod Pending, blocked by low-priority pod's resource reservation. Both need ~500m CPU each, node has ~1000m total.

## Fix

Create PriorityClass and assign to high-priority pod to enable preemption:

```bash
kubectl apply -f - <<'MANIFEST'
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
globalDefault: false
description: "High priority for critical workloads"
MANIFEST

kubectl patch pod -n priority-test high-priority -p '{"spec":{"priorityClassName":"high-priority"}}'
```

Pod will then preempt low-priority pod and transition to Running.

## Why

Pods without priorityClassName default to priority 0. High priority classes (value > 0) can preempt lower-priority pods when resources constrained. This ensures critical workloads run even under resource pressure.
