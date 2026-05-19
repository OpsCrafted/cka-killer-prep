# s06: Scheduler Unresponsive — Solution

## Diagnosis Path

Pods pending: scheduler can't find node matching nodeSelector.

**Step 1:** Identify issue
```bash
kubectl describe pod <pending-pod>
# Events: "no nodes match nodeSelector"
```

**Step 2:** Check selector requirement
```bash
kubectl get pod <name> -o yaml | grep -A 5 nodeSelector
```

**Step 3:** Check node labels
```bash
kubectl get nodes --show-labels
```

**Step 4:** Add missing label
```bash
kubectl label node <node-name> node-type=compute
```

**Step 5:** Pod schedules
```bash
kubectl get pods
```

## Commands Used

```bash
kubectl describe pod <name>
kubectl get pod <name> -o yaml | grep -A 5 nodeSelector
kubectl get nodes --show-labels
kubectl label node <node-name> node-type=compute
```

## Why This Fix Works

No node has required labels. Scheduler can't place pod. Adding label makes node eligible.

## Common Wrong Fixes

- **Restarting scheduler** — Scheduler is OK; problem is labels.
- **Removing nodeSelector** — Defeats scheduling constraint.
