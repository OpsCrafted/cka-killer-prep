# s29: GatewayClass Binding — Controller Reconciliation

## Problem Statement

GatewayClass is created, but the controller never "acknowledges" it. Gateways referencing this GatewayClass remain unschedulable because the controller won't reconcile them.

## Architecture: Controller Reconciliation Loop

```
┌──────────────────────────────────────┐
│   User Creates GatewayClass          │
│   controllerName: example.com/demo   │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│   API Server Stores GatewayClass     │
│   status.conditions = []             │
└──────────────┬───────────────────────┘
               │
       ┌───────┴────────┐
       │                │
       ▼                ▼
  ┌─────────────┐  ┌──────────────────┐
  │  Controller │  │  No Controller?  │
  │  Pod        │  │  Status never    │
  │  Running?   │  │  updates         │
  └──────┬──────┘  └──────────────────┘
         │
    YES │
         ▼
  ┌──────────────────────────────────────┐
  │ Controller Watches GatewayClass      │
  │ Checks: controllerName == "demo"?    │
  └──────────────┬───────────────────────┘
                 │
         ┌───────┴────────┐
         │                │
        YES              NO
         │                │
         ▼                ▼
  ┌────────────┐  ┌──────────────────┐
  │  Accept!   │  │ Ignore           │
  │ Update     │  │ Another ctrl     │
  │ status:    │  │ handles it       │
  │ Accepted   │  └──────────────────┘
  │ = true     │
  └────────────┘
```

## GatewayClass Status Conditions

When a controller accepts a GatewayClass:

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: example-gc
spec:
  controllerName: example.com/gateway-controller
status:
  conditions:
  - type: Accepted
    status: "True"
    reason: ValidGatewayClass
    message: "GatewayClass accepted"
  - type: Programmed
    status: "False"
    reason: WaitingForController
    message: "Waiting for Gateways to be programmed"
```

### Condition Types

| Condition | Meaning | What triggers it |
|-----------|---------|-----------------|
| **Accepted** | Controller recognized this GatewayClass | Controller running and matches controllerName |
| **Programmed** | Gateways derived from this class are running | Gateway + all listeners actually listening |

## Common Issues: Controller Binding

### Issue 1: Controller Not Running
```
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: demo
spec:
  controllerName: example.com/demo  ← Controller pod is crashed/not deployed
status:
  conditions: []  ← Empty! No controller acknowledged it
```

**Debug:**
```bash
kubectl get gatewayclass demo -o yaml | grep -A 5 status.conditions
# Shows: No conditions or Accepted: false

# Check if controller pod exists
kubectl get pods --all-namespaces | grep -i gateway
# Result: Nothing found
```

**Fix:** Deploy controller pod

### Issue 2: Wrong controllerName
```yaml
spec:
  controllerName: example.com/gateway-controller  ← Controller expects "demo"
```

The running controller only watches GatewayClasses with `controllerName: example.com/demo`. This one won't match.

**Debug:**
```bash
# Check what controllerName the pod is configured for
kubectl logs -n gateway-system gateway-controller-1234 | grep controllerName
# or check deployment args:
kubectl describe deployment -n gateway-system gateway-controller
```

**Fix:** Correct controllerName to match controller config

### Issue 3: Multiple Controllers, Wrong One Active
```
Cluster has:
- nginx-gateway controller (active, watching "nginx")
- envoy-gateway controller (active, watching "envoy")

GatewayClass:
  controllerName: example.com/custom  ← No one is watching this!
```

**Debug:**
```bash
kubectl get pods -A | grep gateway
# See which controllers exist

for pod in $(kubectl get pods -n gateway-system -o name); do
  kubectl logs $pod | grep "watching controllerName" || true
done
```

**Fix:** Use one of the active controllerName values

### Issue 4: Controller RBAC Broken
```
Controller pod running but no permissions to:
- Create/Update GatewayClass status
- Watch GatewayClass resources
- Create/Manage Gateways
```

**Debug:**
```bash
# Check controller logs for permission errors
kubectl logs -n gateway-system gateway-controller-xxx | grep -i "forbidden\|permission\|rbac"

# Check ServiceAccount RBAC
kubectl describe sa -n gateway-system gateway-controller
kubectl describe role -n gateway-system gateway-controller
```

**Fix:** Update controller's ClusterRole with necessary permissions

## Solution Flow

```
1. Verify controller pod is running
   ▼
2. Identify the controllerName the pod watches
   ▼
3. Verify GatewayClass controllerName matches
   ▼
4. Check controller logs for errors
   ▼
5. Verify controller has RBAC permissions
   ▼
6. If all OK, GatewayClass status.conditions.Accepted should be true
```

## Debugging Commands

```bash
# 1. Check all GatewayClasses and their status
kubectl get gatewayclass -A -o wide
kubectl describe gatewayclass example-gc

# 2. Check condition details
kubectl get gatewayclass example-gc -o json | jq '.status.conditions'

# 3. Find running gateway controllers
kubectl get pods -A | grep -i gateway

# 4. Check controller logs for errors
kubectl logs -n <ns> <pod-name> | tail -50

# 5. Check controller configuration
kubectl describe deployment -n <ns> <controller-name> | grep -A 10 "Args:"

# 6. Verify RBAC
kubectl get clusterrole | grep gateway
kubectl describe clusterrole <gateway-role> | grep GatewayClass

# 7. Check if controller is watching the right controllerName
kubectl get gatewayclass -o yaml | grep controllerName
```

## When Binding Fails

| Symptom | Root Cause | Check | Fix |
|---------|-----------|-------|-----|
| `conditions: []` | Controller not running | `kubectl get pods -A \| grep gateway` | Deploy controller |
| `Accepted: false` | Wrong controllerName | Controller logs | Update GatewayClass controllerName |
| `Accepted: false` | RBAC broken | Controller logs for "forbidden" | Add permissions to ServiceAccount |
| `Programmed: false` | Gateways not scheduling | Gateway describe | Often follows acceptance; wait or check Gateway status |
| Multiple controllers but status blank | Ambiguous controllerName | Clear controllerName | Use one of: nginx, envoy, etc. |

## Key Learning Points

1. **GatewayClass is just metadata** — it doesn't do anything until a controller watches it
2. **controllerName is the key** — controller must match `spec.controllerName` exactly
3. **Status tells the story** — `status.conditions` shows if controller acknowledged it
4. **Controller selection** — one controllerName per GatewayClass; multiple controllers can coexist
5. **RBAC is critical** — controller needs permissions to read/write GatewayClass status

## Common Patterns

### Pattern 1: Single Controller Cluster
```yaml
# One nginx controller watching "nginx"
GatewayClass:
  controllerName: k8s.io/ingress-nginx
```

### Pattern 2: Multi-Controller Cluster
```yaml
# Multiple controllers, pick one per GatewayClass
GatewayClass nginx:
  controllerName: k8s.io/ingress-nginx

GatewayClass envoy:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller

GatewayClass cilium:
  controllerName: io.cilium/gateway-controller
```

## Testing Steps

Without a real controller running:

```bash
# 1. Create a fake GatewayClass
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: test-gc
spec:
  controllerName: test.example.com/fake-controller
EOF

# 2. Check status (will be empty if no controller exists)
kubectl get gatewayclass test-gc -o yaml

# 3. Try to create Gateway referencing it
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: test-gw
spec:
  gatewayClassName: test-gc
  listeners:
  - name: http
    port: 80
    protocol: HTTP
EOF

# 4. Check Gateway status (likely Pending)
kubectl get gateway test-gw -o yaml | grep -A 10 conditions
```

If controller was running, Accepted would be true.
