#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

kubectl create namespace storage-test 2>/dev/null || true

# PersistentVolume
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  hostPath:
    path: /tmp/pv-data
MANIFEST

# PersistentVolumeClaim (unbound — needs binding)
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-claim
  namespace: storage-test
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
MANIFEST

# Test pod (won't run until PVC binds)
kubectl apply -f - <<'MANIFEST' 2>/dev/null || true
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
MANIFEST

echo "✓ Scenario setup complete: PVC pending binding, pod waiting"
