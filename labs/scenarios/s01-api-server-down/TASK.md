# Scenario s01: Control Plane API Server Offline

## Problem

Your monitoring alerts fired: "API server unreachable (5xx errors)." Kubectl commands hang, new pods won't schedule, and users report timeout errors.

Check what happened to the Kubernetes API server. Restart it if needed.

## Expected State

- Control plane API server is Running
- kubectl commands respond immediately
- All nodes report Ready status
- New pods can be scheduled

## Time Limit

15 minutes

## Exam Notes

- No external documentation allowed
- Use only kubectl and docker exec
- Minimize changes to cluster state
