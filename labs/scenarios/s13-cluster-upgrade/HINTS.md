# Hints for s13: Rolling upgrade across nodes

## Step 1: Diagnose cordoned node

```bash
kubectl get nodes
# Look for any node with status "Ready,SchedulingDisabled"
```

The issue is that one node is cordoned (unschedulable), preventing new pods from being scheduled.

## Step 2: Understand why pods are failing to reschedule

```bash
kubectl describe deployment upgrade-app
# Note: desired != ready replicas

kubectl get pods -o wide
# Some pods may be on the cordoned node, can't reschedule
```

## Step 3: Fix the node

Use one of these approaches:

**Option A:** Uncordon the node
```bash
kubectl uncordon <node-name>
# Pods will reschedule to available nodes
```

**Option B:** Edit the node to remove the unschedulable taint
```bash
kubectl edit node <cordoned-node>
# Remove: spec.unschedulable: true
```

## Common Mistakes

- **Deleting pods manually** — they'll reschedule with the same issue
- **Not understanding cordoning** — cordon prevents NEW pods, existing ones stay
- **Confusing cordoning with draining** — drain = cordone + evict; cordone = just prevent new scheduling

## Key Commands

```bash
kubectl get nodes -o wide
kubectl describe node <name>
kubectl cordon <node>
kubectl uncordon <node>
kubectl get deployment <name> -o wide
```
