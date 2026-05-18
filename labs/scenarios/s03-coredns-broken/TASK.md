# Scenario s03: CoreDNS Pod Crash Loop

## Problem

Service DNS resolution is failing. Pods can't reach services by name. CoreDNS is stuck in CrashLoopBackOff.

Fix the CoreDNS deployment so DNS queries work again.

## Expected State

- CoreDNS pod is Running (not CrashLoopBackOff)
- Service DNS resolves: `nslookup kubernetes.default` returns 10.96.0.1
- Pods can reach services by name

## Time Limit

15 minutes
