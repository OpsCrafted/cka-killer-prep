# Hints for s11: etcd Restore

## Symptoms
- Namespace or resources missing
- etcd needs restoration from backup

## Debugging Path
1. Check if namespace exists: `kubectl get namespace critical-app`
2. Find etcd backup file: `/tmp/etcd-backup/backup.db`
3. Restore from snapshot (complex — refer to kubeadm docs)
4. Basic restore steps:
   - Stop API server and etcd
   - Run etcdctl snapshot restore --data-dir=/tmp/etcd-restore /tmp/etcd-backup/backup.db
   - Move restored data
   - Restart etcd and API server
5. Verify namespace is back: `kubectl get namespace`

## Key Commands
- `kubectl get namespace`
- `docker exec <cluster>-control-plane etcdctl member list`
- `docker exec <cluster>-control-plane etcdctl snapshot save <file>`
