# Scenario s20: RBAC design - role-based access control

## Problem

RBAC policy is incomplete or misconfigured. Service account has insufficient permissions for its workload.

**Symptoms:**
- Pods getting permission denied errors
- ServiceAccount unable to access API resources
- Deployment logs show "forbidden" errors

## Expected State

- ServiceAccount has appropriate permissions
- RBAC rules allow required API operations
- Workload functions without permission errors

## Time Limit

15 minutes
