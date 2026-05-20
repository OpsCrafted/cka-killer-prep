# s24: Gateway API — System Design & Concepts

## What is Gateway API?

Gateway API is the next-generation ingress model for Kubernetes (replacing Ingress). It provides:
- **GatewayClass**: Defines the ingress controller/implementation (e.g., nginx, Envoy, HAProxy)
- **Gateway**: Instance of a GatewayClass; listens on ports and protocols
- **HTTPRoute/TCPRoute**: Routes traffic rules (replaces Ingress)

```
┌─────────────────────────────────────────────┐
│         External Traffic                     │
└────────────────┬────────────────────────────┘
                 │
          ┌──────▼──────┐
          │  Gateway    │  (listens on :80, :443)
          │ (my-gateway)│  Status: Ready/Programmed
          └──────┬──────┘
                 │
         ┌───────┴───────┐
         │               │
    ┌────▼────┐    ┌────▼────┐
    │HTTPRoute│    │TCPRoute │
    │/app/*   │    │:5000    │
    └────┬────┘    └────┬────┘
         │              │
    ┌────▼────┐    ┌────▼────┐
    │Service  │    │Service  │
    │app-svc  │    │db-svc   │
    └─────────┘    └─────────┘
```

## Architecture Components

### GatewayClass (Cluster-scoped)
- Points to a controller implementation (e.g., "gateway.networking.k8s.io/gateway-class")
- One per cluster (usually)
- Defines which controller will implement Gateways

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: k8s.io/ingress-nginx
```

### Gateway (Namespace-scoped)
- Instance of a GatewayClass
- Defines listeners (port, protocol, hostname)
- Must be owned by GatewayClass and controller

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: my-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
```

### Routes (HTTPRoute, TCPRoute, etc.)
- Actual traffic routing rules
- References a Gateway for attachment
- Defines backend services

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: app-route
spec:
  parentRefs:
  - name: my-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /app
    backendRefs:
    - name: app-service
      port: 80
```

## Common Failure Modes

### 1. **Controller Not Installed**
- **Symptom**: GatewayClass created, but Gateway stays Pending/Not Ready
- **Root cause**: Controller specified in GatewayClass doesn't exist
- **Debug**: `kubectl get gatewayclass -o yaml` → check `status.conditions`
- **Fix**: Install correct controller (nginx, envoy, etc.)

### 2. **Wrong Controller Name**
- **Symptom**: Gateway created but not reconciled
- **Root cause**: `gatewayClassName` doesn't match any GatewayClass
- **Debug**: `kubectl describe gateway` → shows "invalid gatewayClassName"
- **Fix**: Correct the gatewayClassName

### 3. **Listener Port Already in Use**
- **Symptom**: Gateway stuck in Conflict status
- **Root cause**: Another pod on node already listening on port 80/443
- **Debug**: Check node events, pod logs
- **Fix**: Free up port or use different port

### 4. **Route Can't Find Backend Service**
- **Symptom**: Route created but traffic routes to 404/503
- **Root cause**: Service name wrong or doesn't exist
- **Debug**: `kubectl get service`, check route backendRefs
- **Fix**: Correct service name and verify it exists

### 5. **Certificate/TLS Not Configured**
- **Symptom**: HTTPS listener exists but no certificate
- **Root cause**: Listener protocol is HTTPS but no certificateRef
- **Debug**: Check listener.tls.certificateRefs
- **Fix**: Reference a Secret with tls.crt and tls.key

## Debugging Checklist

```bash
# 1. Check if Gateway API is supported
kubectl api-resources | grep gateway

# 2. List GatewayClasses (should see at least one)
kubectl get gatewayclass
kubectl describe gatewayclass nginx

# 3. Check Gateway status (should be Programmed=true)
kubectl get gateway
kubectl describe gateway my-gateway
kubectl get gateway my-gateway -o json | jq '.status'

# 4. Check if Gateway has an Address (IP/hostname assigned)
kubectl get gateway -o wide

# 5. Check Route attachment
kubectl get httproute
kubectl describe httproute app-route

# 6. Check service exists and has endpoints
kubectl get svc app-service
kubectl get endpoints app-service

# 7. Check controller pods are running
kubectl get pods -n <controller-namespace>
kubectl logs -n <controller-namespace> <controller-pod>
```

## Key Concepts

| Concept | Ingress | Gateway API |
|---------|---------|-------------|
| Routing definition | One Ingress per app | Separate HTTPRoute per rule |
| Load balancer config | Embedded in Ingress | Separate Gateway resource |
| Multi-tenancy | Hard (one LB per cluster) | Better (Gateway = LB) |
| Protocols | HTTP/HTTPS only | HTTP/HTTPS/TCP/UDP |
| Cross-namespace routing | Limited | Explicit via parentRefs |
| Status | Limited | Detailed per listener/route |

## When Gateway API Breaks

| Situation | Why | Fix |
|-----------|-----|-----|
| GatewayClass exists, Gateway stuck Pending | Controller not installed or crashed | Deploy controller pod |
| Gateway Ready, Route not attaching | parentRef wrong or Route in wrong namespace | Fix parentRef name, check permissions |
| Traffic goes to 404 | Route backendRef invalid | Verify service exists in same/correct namespace |
| Port in use (Conflict) | Node port taken by another app | Use different port or reschedule |
| TLS not working | No certificateRef on listener | Add listener.tls.certificateRefs |

## Testing Approach

Since Gateway API requires a controller:
1. Deploy GatewayClass + Gateway
2. Check `gateway.status.conditions` for "Programmed"
3. If false, check controller logs for why it didn't accept it
4. Deploy HTTPRoute pointing to a service
5. Check route status for attachment success
6. Test connectivity (port-forward to gateway IP:port)

## Further Reading

- [Gateway API Concepts](https://gateway-api.sigs.k8s.io/concepts/api-overview/)
- [Gateway API Routing](https://gateway-api.sigs.k8s.io/guides/routing/)
- Implementation: nginx-gateway, Envoy Gateway, Cilium, etc.
