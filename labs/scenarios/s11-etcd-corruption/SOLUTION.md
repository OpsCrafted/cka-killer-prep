# s11: etcd Corruption & Restore — Solution

## Diagnosis

**Confirm data loss:**
```bash
kubectl get namespace critical-app
```

**Find backup:**
```bash
docker exec <cluster>-control-plane ls -la /tmp/etcd-backup/
```

## Recovery

**Restore:**
```bash
docker exec <cluster>-control-plane sh -c \
  "ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup/backup.db --data-dir=/var/lib/etcd-restore"

docker exec <cluster>-control-plane systemctl stop kubelet
docker exec <cluster>-control-plane sh -c \
  "mv /var/lib/etcd /var/lib/etcd-corrupted && \
   mv /var/lib/etcd-restore /var/lib/etcd"

docker exec <cluster>-control-plane systemctl start kubelet
```

**Verify:**
```bash
kubectl get namespace critical-app
```

## Why

etcd is source of truth. Restore from backup rebuilds state.
