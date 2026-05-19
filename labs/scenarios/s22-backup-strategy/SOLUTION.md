# s22: Backup Strategy — Solution

## Diagnosis

```bash
docker exec <cluster>-control-plane ls -la /tmp/etcd-backup/
```

## Fix

```bash
docker exec <cluster>-control-plane mkdir -p /tmp/etcd-backup
docker exec <cluster>-control-plane sh -c \
  "ETCDCTL_API=3 etcdctl --endpoints=127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    snapshot save /tmp/etcd-backup/backup.db"
```

**Verify:**
```bash
docker exec <cluster>-control-plane ls -lh /tmp/etcd-backup/
```

## Why

Backup enables disaster recovery.

## Mistakes

- Wrong cert/key paths
- Missing directory
