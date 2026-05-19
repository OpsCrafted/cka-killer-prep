# s02: Worker Node Not Ready — Solution

## Diagnosis Path

The worker node's kubelet service was stopped. When kubelet stops, the node goes NotReady and pods are evicted. Your task is to identify which node is down and restart its kubelet.

**Step 1:** Identify the NotReady node
```bash
kubectl get nodes
# One node will show NotReady status
```

**Step 2:** Get details on the node's condition
```bash
kubectl describe node <node-name>
# Look at Conditions section; will show KubeletNotReady, MemoryPressure, or similar
```

**Step 3:** Access the node and check kubelet status
```bash
docker exec <cluster-name>-worker bash
systemctl status kubelet
# Will show "inactive (dead)"
```

**Step 4:** Restart kubelet
```bash
docker exec <cluster-name>-worker systemctl restart kubelet
# Watch it come back
```

**Step 5:** Verify node recovers to Ready
```bash
kubectl get nodes
kubectl describe node <node-name>
# Should show Ready and no pressure conditions
```

## Commands Used

```bash
# Diagnose
kubectl get nodes
kubectl describe node <node-name>
docker exec <cluster-name>-worker systemctl status kubelet
docker exec <cluster-name>-worker journalctl -u kubelet -n 20

# Fix
docker exec <cluster-name>-worker systemctl restart kubelet

# Verify
kubectl get nodes
kubectl describe node <node-name>
```

## Why This Fix Works

Kubelet is the node's agent that reports node status to the API server. When kubelet stops, the node cannot check in, so the API server marks it NotReady. Restarting kubelet allows it to resume heartbeat, and the node transitions back to Ready. Any pods previously evicted don't automatically reschedule — you'd need to redeploy them.

## Common Wrong Fixes

- **Trying to patch node status directly** — The node status is read-only; you must fix the underlying kubelet.
- **Checking container logs instead of journalctl** — Kubelet is a host process, not a container; check journalctl on the node.
- **Not checking which worker is affected** — Use `kubectl get nodes` first; there may be multiple workers.
- **Assuming the fix is the pod/deployment** — The problem is the node itself, not the workload.
- **Rebooting the node instead** — Restarting kubelet is sufficient; full reboot is overkill.
