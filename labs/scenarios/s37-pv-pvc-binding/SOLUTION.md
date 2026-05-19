# s37: PV/PVC Binding — Solution

## Diagnosis

```bash
kubectl get pv,pvc
```

## Fix

**Create PV:**
```bash
kubectl apply -f - << 'PVEOF'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-1
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /mnt/data
PVEOF
```

**Create PVC:**
```bash
kubectl apply -f - << 'PVCEOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-1
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
PVCEOF
```

## Why

PVC binds to matching PV. Binding enables pod mounts.
