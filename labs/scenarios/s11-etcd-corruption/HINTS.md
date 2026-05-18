# Hints for s11: etcd Corruption & Restore

## Symptoms
- Namespace `critical-app` is missing
- Associated resources (Deployment, ConfigMap) are gone
- etcd data has been deleted/corrupted

## Investigation
1. Confirm namespace is missing:
   ```bash
   kubectl get namespace critical-app
   ```

2. Find the etcd backup in the control plane:
   ```bash
   docker exec <CLUSTER_NAME>-control-plane ls -la /tmp/etcd-backup/
   ```

## Recovery Steps

### Restore using etcdctl snapshot restore
```bash
# Restore snapshot to temporary directory inside control plane
docker exec <CLUSTER_NAME>-control-plane \
  sh -c "ETCDCTL_API=3 etcdctl snapshot restore \
    /tmp/etcd-backup/backup.db \
    --data-dir=/var/lib/etcd-restore"

# Stop kubelet to prevent API server from starting with old data
docker exec <CLUSTER_NAME>-control-plane \
  sh -c "systemctl stop kubelet"

# Backup corrupted data and restore from snapshot
docker exec <CLUSTER_NAME>-control-plane \
  sh -c "mv /var/lib/etcd /var/lib/etcd-corrupted && \
         mv /var/lib/etcd-restore /var/lib/etcd"

# Restart kubelet (etcd and API server will restart automatically)
docker exec <CLUSTER_NAME>-control-plane \
  sh -c "systemctl start kubelet"

# Wait for API server to become ready
sleep 10
kubectl get nodes
```

## Verification
Once restored, check that resources are back:
```bash
kubectl get namespace critical-app
kubectl get all -n critical-app
kubectl get configmap critical-config -n critical-app -o jsonpath='{.data}'
```

## Key Learning
- etcd is the source of truth for all cluster state
- Always maintain current backups: `etcdctl snapshot save`
- Practice restore procedures — this is critical operational knowledge
