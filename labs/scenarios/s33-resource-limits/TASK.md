# Scenario s33: Resource limits - CPU/memory enforcement

## Problem
Resource limits not enforced. Pods can consume unlimited CPU/memory. LimitRange or requests missing.

## Expected State
- Resource requests/limits configured
- LimitRange enforcing defaults
- Pods respect resource constraints

## Time Limit
10 minutes
