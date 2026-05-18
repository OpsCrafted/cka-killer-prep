# Hints for s21: ServiceAccount Cross-Namespace Binding

## Problem
ServiceAccount `app-reader` in the `app` namespace needs to read a secret in the `shared` namespace. Currently has no permissions.

## Solution
Create a ClusterRole that allows reading secrets across all namespaces, then bind it to the ServiceAccount:

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

## Verification
Check pod logs to confirm it can read the secret:
```bash
kubectl logs cross-ns-reader -n app
```

## Key Learning
- ClusterRoles apply across all namespaces (unlike Roles)
- ClusterRoleBindings connect ClusterRoles to subjects
- ServiceAccounts can have cross-namespace permissions with proper RBAC
