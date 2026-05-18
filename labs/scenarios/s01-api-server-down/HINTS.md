# Hints for s01: API Server Down

## Symptoms to Look For

- kubectl commands hang or return connection errors
- Nodes may show NotReady status
- New pods won't be scheduled

## Debugging Path

1. **Check if API server pod is running:**
   ```
   docker exec <cluster-name>-control-plane kubectl get pods -n kube-system | grep kube-apiserver
   ```

2. **Look for API server crashes:**
   ```
   docker exec <cluster-name>-control-plane journalctl -u kubelet | tail -50
   ```

3. **If API server process is gone, restart kubelet:**
   ```
   docker exec <cluster-name>-control-plane systemctl restart kubelet
   ```

4. **Verify API server is responding:**
   ```
   kubectl get nodes
   kubectl get pods -A
   ```

## Key Commands

- `kubectl cluster-info` — shows API server endpoint
- `kubectl get events -A` — system events
- `docker logs <container>` — container logs
