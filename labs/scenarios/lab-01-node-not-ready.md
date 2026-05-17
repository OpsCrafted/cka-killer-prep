# Lab 01: Node Not Ready

**Domain:** Troubleshooting (30%)
**Difficulty:** Easy
**Time target:** 3 minutes

## Scenario

One of your worker nodes has gone NotReady. Workloads on that node are being evicted. Find the node, diagnose the issue, and restore it to Ready state.

## Setup

```bash
./scripts/break.sh lab-01-node-not-ready
```

## Your task

1. Identify which node is NotReady
2. SSH into the affected node
3. Diagnose why it's NotReady
4. Fix it
5. Verify all nodes are Ready

## Verify

```bash
./scripts/verify.sh lab-01-node-not-ready
```

---

<details>
<summary>💡 Hint 1</summary>

Check the kubelet service status on the affected node.
</details>

<details>
<summary>💡 Hint 2</summary>

`systemctl status kubelet` will tell you if it's running or stopped.
</details>

<details>
<summary>📖 Solution</summary>

```bash
# Find the NotReady node
kubectl get nodes

# SSH into it
docker exec -it cka-lab-worker bash

# Check kubelet
systemctl status kubelet
# → inactive (dead)

# Start it
systemctl start kubelet
systemctl enable kubelet

# Exit and verify
exit
kubectl get nodes
# All Ready
```

**Why it broke:** The kubelet process was stopped. Without kubelet, the node can't communicate with the control plane and goes NotReady after ~40 seconds.

**Exam tip:** `systemctl status kubelet` is always your first command when a node is NotReady. If it's running but erroring, check `journalctl -u kubelet -f`.
</details>
