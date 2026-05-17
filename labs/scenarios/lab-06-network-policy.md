# Lab 06: NetworkPolicy

## Scenario

A microservices cluster has two namespaces:
- `client`: pod `frontend` needs to call `api` service in the `backend` namespace
- `backend`: pod `api` should only accept traffic from `frontend` in the client namespace

A NetworkPolicy has been created but **the ingress rule is misconfigured**. Traffic is blocked when it should be allowed.

## What's Broken

The NetworkPolicy selector references the wrong pod labels or namespace. The `frontend` pod in the `client` namespace cannot reach the `api` pod in the `backend` namespace.

```
frontend (client ns) → [timeout] → api (backend ns)
```

## Your Task

1. **Diagnose** the NetworkPolicy rule in the `backend` namespace
2. **Identify** the selector mismatch (pod labels don't match the rule, or namespace selector is wrong)
3. **Fix** the NetworkPolicy to allow traffic from `frontend` in `client` namespace to `api` in `backend` namespace
4. **Verify** by running a `curl` from the `frontend` pod to the `api` service

## Commands to Get Started

```bash
kubectl get networkpolicy -n backend
kubectl describe networkpolicy <name> -n backend
kubectl get pods -n client --show-labels
kubectl get pods -n backend --show-labels
kubectl exec -it -n client frontend -- curl http://api.backend.svc.cluster.local:8080
kubectl edit networkpolicy <name> -n backend
```

## What You Should See

After fixing the NetworkPolicy, the curl request should succeed with HTTP 200.

## Solution Outline

- The ingress rule likely references wrong `podSelector` labels or `namespaceSelector` is misconfigured
- Fix the selector in the NetworkPolicy to match the actual pod labels and namespace labels
