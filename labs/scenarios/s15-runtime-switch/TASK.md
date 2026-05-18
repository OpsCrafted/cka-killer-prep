# Scenario s15: Runtime switch - container runtime migration

## Problem

Cluster is running containerd, but needs to be switched to a different container runtime. One node is misconfigured with wrong runtime binary path.

**Symptoms:**
- Node shows NotReady
- `kubectl describe node` shows runtime error
- Pods fail to start

## Expected State

- Node runtime properly configured
- Node is Ready
- Pods can be scheduled and run

## Time Limit

10 minutes
