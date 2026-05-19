# s01: Control Plane API Server Offline — Solution

## Diagnosis Path

The API server container was killed (pkill -f kube-apiserver). When the control plane's kubelet detects the process is gone, it automatically restarts it. Your job is to identify the problem and trigger the restart.

**Step 1:** Verify API server is actually down
```bash
kubectl cluster-info
# Will hang or return connection refused
```

**Step 2:** Check if API server pod exists in kube-system
```bash
docker exec <cluster-name>-control-plane kubectl get pods -n kube-system | grep kube-apiserver
# Pod exists but process may be stopped
```

**Step 3:** Check kubelet logs for restart events
```bash
docker exec <cluster-name>-control-plane journalctl -u kubelet | tail -50
# Look for "Starting container" or "API server" restarts
```

**Step 4:** Restart the control plane kubelet to force restart of static pods
```bash
docker exec <cluster-name>-control-plane systemctl restart kubelet
```

**Step 5:** Verify recovery
```bash
kubectl get nodes
kubectl get pods -A
```

## Commands Used

```bash
# Diagnose
kubectl cluster-info
docker exec <cluster-name>-control-plane kubectl get pods -n kube-system | grep kube-apiserver
docker exec <cluster-name>-control-plane journalctl -u kubelet | tail -50

# Fix
docker exec <cluster-name>-control-plane systemctl restart kubelet

# Verify
kubectl get nodes
kubectl cluster-info
```

## Why This Fix Works

The kube-apiserver runs as a static pod on the control plane. Static pods are managed directly by kubelet — when the process dies, kubelet automatically restarts it. By restarting kubelet itself, we force it to re-sync all static pod manifests and restart any dead containers. The API server comes back online and the cluster recovers.

## Common Wrong Fixes

- **Trying to use kubectl to fix it** — kubectl can't work if the API server is down. You need docker exec to access the control plane.
- **Not restarting kubelet** — The API server may auto-restart soon anyway, but explicitly restarting kubelet is faster and more reliable.
- **Looking in pod logs too early** — The pod may not exist yet; check journalctl on the host instead.
- **Assuming it's a networking issue** — In this scenario, the problem is a dead process, not networking.
