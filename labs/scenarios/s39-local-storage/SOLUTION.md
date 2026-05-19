# s39: Local Storage — Solution

## Diagnosis

```bash
kubectl get pv
```

## Fix

**Create local PV:**
```bash
kubectl apply -f - << 'LPVEOF'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  local:
    path: /mnt/disk1
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node-name
LPVEOF
```

## Why

Local storage ties PV to specific node. Fast but not portable.
