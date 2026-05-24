# Scenario s01: Control Plane API Server Offline

## Problem

Your monitoring alerts fired: "API server unreachable." `kubectl` commands hang with connection refused. The cluster was working 10 minutes ago — no deployments changed, but someone was doing maintenance on the control plane node.

Diagnose why the API server is not starting and fix it.

## Expected State

- `kubectl get nodes` responds immediately
- All nodes report `Ready`
- `demo-app` deployment has 2/2 pods Running

## Time Limit

15 minutes

## Constraints

- Do not delete or recreate the cluster
- Fix the root cause — do not just restart services blindly
- Use `docker exec` to access nodes
