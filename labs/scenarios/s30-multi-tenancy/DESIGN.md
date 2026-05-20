# s30: Multi-Tenancy — Enforcing Tenant Isolation

## Problem Statement

Kubernetes cluster hosts multiple independent teams (tenants). Each tenant needs:
1. **Namespace isolation** — own namespace, can't see others' namespaces
2. **Network isolation** — pods can't talk across tenant boundaries
3. **RBAC isolation** — ServiceAccounts can't access other tenants' resources
4. **Storage isolation** — PVCs can't be accessed by other tenants
5. **Quota/limits** — each tenant has resource budgets

Without multi-tenancy controls, one tenant can:
- Access another tenant's secrets
- Delete another tenant's workloads
- Consume all cluster resources
- Exfiltrate data from other tenants

## Architecture: Multi-Tenant Isolation Layers

```
┌─────────────────────────────────────────────┐
│     Cluster Admin Console                    │
│     (Full cluster access)                    │
└──────────────────┬──────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
   ┌────▼─────┐         ┌────▼─────┐
   │ Tenant A  │         │ Tenant B  │
   │ namespace-a         │ namespace-b
   └──────┬────┘         └──────┬────┘
          │                     │
      ┌───┴─────────┬───────────┴───┐
      │             │               │
  ┌───▼────┐   ┌───▼────┐     ┌───▼────┐
  │RBAC    │   │Network │     │Quota   │
  │Policy  │   │Policy  │     │Limits  │
  └────────┘   └────────┘     └────────┘
      │             │               │
      ▼             ▼               ▼
  ┌─────────────────────────────────────┐
  │   Enforcement: Access Denied        │
  │   Tenant A pod ≠> Tenant B secret   │
  │   Network: blocked                  │
  │   CPU/Memory: limited               │
  └─────────────────────────────────────┘
```

## Isolation Layers

### Layer 1: Namespace Isolation (Admin)
```yaml
# Create separate namespace per tenant
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-a
---
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-b

# By default, namespaces can't prevent access from admin
# But provide logical separation
```

**What it solves:** Logical organization

**What it doesn't:** NetworkPolicy, RBAC needed for actual isolation

### Layer 2: RBAC Isolation (Policy)
```yaml
# Tenant A can only access its namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: tenant-a-role
  namespace: tenant-a
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "create", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tenant-a-binding
  namespace: tenant-a
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: tenant-a-role
subjects:
- kind: ServiceAccount
  name: tenant-a-admin
  namespace: tenant-a
```

**What it solves:** API access control (ServiceAccount can't list pods in other namespace)

**What it doesn't:** Doesn't stop network traffic between pods

### Layer 3: Network Isolation (NetworkPolicy)
```yaml
# Tenant A pods: Deny all incoming from outside namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: tenant-a-isolation
  namespace: tenant-a
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tenant: tenant-a
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          tenant: tenant-a
  - to:
    - namespaceSelector: {}
      ports:
      - protocol: TCP
        port: 53  # DNS only

---

# Same for Tenant B
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: tenant-b-isolation
  namespace: tenant-b
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          tenant: tenant-b
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          tenant: tenant-b
  - to:
    - namespaceSelector: {}
      ports:
      - protocol: TCP
        port: 53
```

**What it solves:** Network traffic isolation (even with shared etcd, pods can't communicate)

**What it doesn't:** Doesn't limit CPU/memory, doesn't prevent API access

### Layer 4: Resource Quotas & Limits
```yaml
# Limit what Tenant A can consume
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-a-quota
  namespace: tenant-a
spec:
  hard:
    requests.cpu: "10"
    requests.memory: "50Gi"
    limits.cpu: "20"
    limits.memory: "100Gi"
    pods: "100"

---

# Default limits for pods in namespace
apiVersion: v1
kind: LimitRange
metadata:
  name: tenant-a-limits
  namespace: tenant-a
spec:
  limits:
  - max:
      cpu: "2"
      memory: "2Gi"
    min:
      cpu: "100m"
      memory: "128Mi"
    type: Container
```

**What it solves:** Fairness (Tenant A can't consume all cluster resources)

**What it doesn't:** Doesn't prevent RBAC access outside namespace

## Common Tenant Escape Paths

### Escape 1: API Server Direct Access
```
Tenant A pod can:
  kubectl get secrets -n tenant-b  ← If RBAC not configured

Fix: ClusterRole/ClusterRoleBinding per tenant
     Only grant access to own namespace
```

### Escape 2: Network Interface Sniffing
```
Tenant A pod can:
  tcpdump -i eth0  ← See Tenant B traffic

Fix: NetworkPolicy (enforced by CNI)
     Must support NetworkPolicy (Calico, Cilium, etc.)
```

### Escape 3: Shared Storage Access
```
Tenant A pod can:
  Mount Tenant B's PVC (if misconfigured)

Fix: PVC in namespace, can only be used in namespace
     StorageClass restricts provisioning
```

### Escape 4: Admission Controller Bypass
```
Tenant A can:
  Deploy privileged container, escape to host

Fix: PodSecurityPolicy/Pod Security Standards
     Restrict: privileged, hostNetwork, hostPath
```

### Escape 5: Resource Limit Circumvention
```
Tenant A can:
  Create many pods to consume all cluster CPU

Fix: ResourceQuota on namespace
     LimitRange on individual containers
```

### Escape 6: RBAC Misconfiguration
```
Tenant A can:
  Bind itself to cluster-admin role

Fix: Audit RBAC bindings
     Use RoleBindings (namespace) not ClusterRoleBindings
     Restrict who can create RoleBindings
```

## Debugging Multi-Tenancy Failures

### Test 1: Can Tenant A read Tenant B secrets?
```bash
# From Tenant A pod
kubectl get secrets -n tenant-b
# Should fail: "forbidden"

# Debug:
kubectl auth can-i get secrets --as=system:serviceaccount:tenant-a:tenant-a-admin --namespace=tenant-b
# Expected: no
```

### Test 2: Can Tenant A pods talk to Tenant B pods?
```bash
# From Tenant A pod
kubectl exec -it <pod-a> -n tenant-a -- curl -I http://<pod-b>.<namespace-b>.svc.cluster.local
# Should timeout

# Debug:
kubectl describe networkpolicy -n tenant-a
kubectl get networkpolicy -n tenant-b
```

### Test 3: Can Tenant A exhaust cluster?
```bash
# Create 1000 pods
kubectl create deployment stress-test --image=nginx --replicas=1000 -n tenant-a

# Check:
kubectl describe resourcequota -n tenant-a
# Should show pods at max

# Check:
kubectl get pods -n tenant-a | wc -l
# Should be limited by ResourceQuota
```

### Test 4: Can Tenant A run privileged containers?
```bash
# Try to create privileged pod
kubectl apply -f - -n tenant-a <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: privileged-test
spec:
  containers:
  - name: test
    image: nginx
    securityContext:
      privileged: true
EOF

# Should fail if Pod Security is enforced
# Check:
kubectl describe ns tenant-a | grep pod-security
```

## Multi-Tenancy Checklist

| Component | Tenant A | Tenant B | Verification |
|-----------|----------|----------|--------------|
| Namespace | tenant-a | tenant-b | `kubectl get ns` |
| RBAC | Role/RoleBinding | Role/RoleBinding | `kubectl auth can-i get pods -n tenant-b` |
| NetworkPolicy | deny-all + allow intra | deny-all + allow intra | `kubectl exec <pod-a> -- curl <pod-b>` |
| ResourceQuota | set | set | `kubectl describe quota -n tenant-a` |
| LimitRange | set | set | `kubectl describe limits -n tenant-a` |
| Pod Security | restricted | restricted | `kubectl label ns tenant-a pod-security.kubernetes.io/enforce=restricted` |
| Secrets | isolated | isolated | `kubectl get secrets -n tenant-a` |
| PVCs | isolated | isolated | PVC in namespace only |

## Complete Multi-Tenant Setup

```bash
# 1. Create namespaces
kubectl create namespace tenant-a
kubectl create namespace tenant-b

# 2. Label namespaces for NetworkPolicy
kubectl label namespace tenant-a tenant=tenant-a
kubectl label namespace tenant-b tenant=tenant-b

# 3. Apply Pod Security standards
kubectl label namespace tenant-a pod-security.kubernetes.io/enforce=restricted

# 4. Create ServiceAccounts
kubectl create serviceaccount tenant-a-admin -n tenant-a
kubectl create serviceaccount tenant-b-admin -n tenant-b

# 5. Apply RBAC (namespace-scoped)
kubectl create role tenant-role -n tenant-a \
  --verb=get,list,create \
  --resource=pods,services,configmaps

kubectl create rolebinding tenant-binding -n tenant-a \
  --role=tenant-role \
  --serviceaccount=tenant-a:tenant-a-admin

# 6. Apply NetworkPolicy
kubectl apply -f tenant-a-netpol.yaml
kubectl apply -f tenant-b-netpol.yaml

# 7. Apply ResourceQuota
kubectl apply -f tenant-a-quota.yaml
kubectl apply -f tenant-b-quota.yaml

# 8. Verify isolation
kubectl auth can-i get pods --as=system:serviceaccount:tenant-a:tenant-a-admin -n tenant-b
# Expected: no
```

## When Multi-Tenancy Breaks

| Issue | Cause | Evidence | Fix |
|-------|-------|----------|-----|
| Tenant A can list Tenant B pods | RBAC too permissive | `kubectl get pods -n tenant-b` succeeds | Restrict Role to namespace |
| Tenant A pods reach Tenant B | No NetworkPolicy | curl between pods succeeds | Deploy NetworkPolicy |
| Tenant A fills disk | No Quota | PVC fills from Tenant A | Add ResourceQuota |
| Tenant A escapes to host | Privileged enabled | `docker ps` succeeds in pod | Enforce Pod Security Standard |
| One tenant gets all CPU | No LimitRange | Single pod uses 100 CPUs | Set LimitRange |

## Key Concepts

1. **Defense in Depth** — Use all 4 layers, not just one
2. **Namespace ≠ Security** — Namespace is just organization
3. **Network != API** — NetworkPolicy stops traffic but not Kubernetes API calls
4. **RBAC != Network** — RBAC controls API but pods still communicate
5. **Shared cluster** — Multi-tenancy adds complexity; consider separate clusters for critical isolation

## Further Hardening

- **Pod Security Admission**: Enforce container security contexts
- **Audit Logging**: Log all API access per tenant
- **Istio/Linkerd**: Service mesh for advanced network policies
- **OPA/Gatekeeper**: Custom admission policies
- **Kube-apiserver flags**: `--enable-priority-and-fairness` for tenant QoS
