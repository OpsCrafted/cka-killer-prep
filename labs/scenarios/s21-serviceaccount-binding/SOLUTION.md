# s21: ServiceAccount Cross-Namespace Binding — Solution

## Diagnosis

```bash
kubectl get sa -A
kubectl describe sa app-reader -n app
kubectl auth can-i get secrets --as=system:serviceaccount:app:app-reader --namespace=shared
```

## Fix

**Create ClusterRole + ClusterRoleBinding:**
```bash
kubectl apply -f - << 'RBAC'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: app-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: app-reader
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: app-reader
subjects:
- kind: ServiceAccount
  name: app-reader
  namespace: app
RBAC
```

**Verify:**
```bash
kubectl auth can-i get secrets --as=system:serviceaccount:app:app-reader --namespace=shared
```

## Why

ClusterRole is global; Role is namespace-scoped.

## Mistakes

- Using Role instead of ClusterRole
- Wrong namespace in subject
