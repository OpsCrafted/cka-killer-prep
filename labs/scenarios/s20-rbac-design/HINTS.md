# Hints for s20

Create a Role and RoleBinding for the ServiceAccount:
\`\`\`bash
kubectl apply -f - << 'RBAC'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: rbac-test
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-rolebinding
  namespace: rbac-test
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: app-role
subjects:
- kind: ServiceAccount
  name: app-sa
RBAC
\`\`\`

Key: Know how to create Roles, ClusterRoles, and Bindings.
