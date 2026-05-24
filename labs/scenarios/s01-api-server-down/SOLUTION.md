# s01: Control Plane API Server Offline — Solution

## Root Cause

A bad flag was injected into the kube-apiserver static pod manifest: `--etcd-servers` points to port `2380` (etcd peer port) instead of `2379` (etcd client port). The API server starts, fails to connect to etcd, and crashloops.

## Diagnosis Path

**Step 1:** Confirm API server is down
```bash
kubectl get nodes
# connection refused / EOF
```

**Step 2:** Enter the control plane node
```bash
docker exec -it cka-lab-control-plane bash
```

**Step 3:** Check if API server is crashlooping
```bash
crictl ps -a | grep apiserver
# See high restart count
```

**Step 4:** Read the error
```bash
crictl logs <container-id>
# Look for: "connection refused 127.0.0.1:2380" or similar etcd error
```

**Step 5:** Find the bad flag in the manifest
```bash
grep etcd-servers /etc/kubernetes/manifests/kube-apiserver.yaml
# Shows: --etcd-servers=https://127.0.0.1:2380  ← wrong port
```

**Step 6:** Fix it
```bash
sed -i 's|--etcd-servers=https://127.0.0.1:2380|--etcd-servers=https://127.0.0.1:2379|' \
  /etc/kubernetes/manifests/kube-apiserver.yaml
```

**Step 7:** Wait for kubelet to restart the static pod (~10s), then exit and verify
```bash
crictl ps | grep apiserver   # wait until Running
exit
kubectl get nodes
```

## Why This Fix Works

kube-apiserver is a static pod — kubelet watches `/etc/kubernetes/manifests/` and restarts the pod whenever the file changes. Fixing the manifest is enough; no service restarts needed.

etcd ports:
- `2379` — client port (API server connects here)
- `2380` — peer port (etcd cluster replication, not for clients)

## Commands Used

```bash
# Enter node
docker exec -it cka-lab-control-plane bash

# Diagnose
crictl ps -a | grep apiserver
crictl logs <container-id>
grep etcd-servers /etc/kubernetes/manifests/kube-apiserver.yaml

# Fix
sed -i 's|--etcd-servers=https://127.0.0.1:2380|--etcd-servers=https://127.0.0.1:2379|' \
  /etc/kubernetes/manifests/kube-apiserver.yaml

# Verify inside node
crictl ps | grep apiserver

# Verify from outside
kubectl get nodes
kubectl get pods -n kube-system
```

## Common Wrong Fixes

- **Restarting kubelet** — unnecessary, kubelet already watches the manifest; it will pick up the change automatically
- **Recreating the pod** — static pods can't be deleted via kubectl; edit the manifest
- **Looking for process issues** — the process starts fine, it's the configuration that's wrong
- **Missing the etcd port distinction** — 2379 vs 2380 is a classic mistake; know both ports
