# s37: PV/PVC Binding — Solution

## Diagnosis

Check PV and PVC status:
```bash
kubectl get pv
# PV "local-pv" exists, Available (not bound)

kubectl get pvc -n storage-test
# PVC "app-claim" Pending (not bound)
```

Why they don't bind:
```bash
kubectl get pv local-pv -o jsonpath='{.spec.storageClassName}'
# Returns: "standard"

kubectl get pvc app-claim -n storage-test -o jsonpath='{.spec.storageClassName}'
# Returns: "" (empty - no storageClassName!)
```

## Fix

Add storageClassName to PVC to match PV:
```bash
kubectl patch pvc app-claim -n storage-test -p '{"spec":{"storageClassName":"standard"}}'
```

Verify PVC now Bound:
```bash
kubectl get pvc -n storage-test
# Status: Bound to local-pv
```

Create pod mounting the PVC:
```bash
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: storage-test
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: storage
      mountPath: /data
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: app-claim
EOF
```

## Why

PV and PVC bind when:
1. storageClassName matches (or both empty)
2. accessModes compatible
3. capacity matches

Mismatch in storageClassName = PVC stays Pending indefinitely.

## Key Points

- Empty storageClassName = "default" StorageClass
- Named storageClassName = static provisioning
- PVC won't bind if storageClassName doesn't match
