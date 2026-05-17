# Lab 02: Broken Service

**Domain:** Troubleshooting (30%)
**Difficulty:** Easy
**Time target:** 3 minutes

## Scenario

A deployment `web` in namespace `lab02` has 2 running pods. A service `web-svc` exists but returns connection refused when accessed. Users are complaining they can't reach the application.

## Setup

```bash
./scripts/break.sh lab-02-broken-service
```

## Your task

1. Check if the service exists and what its selector is
2. Check if the service has endpoints
3. Diagnose the mismatch
4. Fix it
5. Verify traffic reaches the pods

## Verify

```bash
./scripts/verify.sh lab-02-broken-service
```

---

<details>
<summary>💡 Hint</summary>

No endpoints = the service selector doesn't match any pod labels. Compare `kubectl describe svc` selector with `kubectl get pods --show-labels`.
</details>

<details>
<summary>📖 Solution</summary>

```bash
# Check endpoints
kubectl -n lab02 get endpoints web-svc
# → <none>

# Check service selector
kubectl -n lab02 describe svc web-svc | grep Selector
# → app=web-frontend

# Check pod labels
kubectl -n lab02 get pods --show-labels
# → app=web

# Fix: edit the service selector
kubectl -n lab02 edit svc web-svc
# Change selector from app: web-frontend to app: web

# Verify endpoints appear
kubectl -n lab02 get endpoints web-svc
```

**Why it broke:** The service selector `app=web-frontend` didn't match the pods' actual label `app=web`. No selector match = no endpoints = no traffic routing.

**Exam tip:** `kubectl get endpoints` is the single most important command for debugging services. If it shows `<none>`, it's always a selector mismatch.
</details>
