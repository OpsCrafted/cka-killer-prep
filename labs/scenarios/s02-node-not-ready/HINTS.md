# Hints for s02: Worker Node Not Ready

## Symptoms

- `kubectl get nodes` shows a node with NotReady status
- Node conditions show MemoryPressure, DiskPressure, or KubeletNotReady
- Pods evicted from that node

## Debugging Path

1. **Check which node is NotReady:**
   ```
   kubectl get nodes
   kubectl describe node <node-name>
   ```

2. **SSH into the node and check kubelet status:**
   ```
   docker exec <cluster-name>-worker bash
   systemctl status kubelet
   journalctl -u kubelet -n 50
   ```

3. **Restart kubelet if stopped:**
   ```
   systemctl restart kubelet
   ```

4. **Verify node recovers:**
   ```
   kubectl get nodes
   ```

## Key Commands

- `kubectl describe node <name>` — shows conditions and resource pressure
- `docker exec <node> systemctl status kubelet`
- `docker exec <node> journalctl -u kubelet`
