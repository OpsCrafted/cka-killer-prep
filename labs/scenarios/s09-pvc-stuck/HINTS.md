# Hints for s09: PVC Stuck in Pending

## Symptoms
- PVC shows "Pending" status
- kubectl describe pvc shows "no PersistentVolume"
- Pod won't start (waiting for PVC to bind)

## Debugging Path
1. Check PVC: `kubectl describe pvc <name>`
2. Look at: storageClassName, accessModes, storage size
3. Check available StorageClasses: `kubectl get storageclass`
4. Does storageClassName exist?
5. If not, create it: `kubectl create storageclass premium-storage --provisioner=kubernetes.io/no-provisioner`
6. Or update PVC to match existing StorageClass

## Key Commands
- `kubectl describe pvc <name>`
- `kubectl get storageclass`
- `kubectl get pv` (list all PersistentVolumes)
- `kubectl edit pvc <name>`
