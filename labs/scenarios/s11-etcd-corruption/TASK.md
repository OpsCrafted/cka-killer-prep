# Scenario s11: Restore Cluster from etcd Backup

## Problem

Critical namespace was accidentally deleted. You need to restore from the etcd backup taken earlier.

Use etcd snapshot restore to recover the deleted namespace and its resources.

## Expected State

- Deleted namespace is restored
- All resources in namespace are present
- etcd is healthy and consistent

## Time Limit

15 minutes
