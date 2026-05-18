# Scenario s17: Custom API - CRD setup

## Problem

Application needs a Custom Resource Definition (CRD) to define custom objects. CRD definition is available but not applied to the cluster.

**Symptoms:**
- Custom resource commands fail: `kubectl get mycustomresource`
- Error: "the server doesn't have a resource type"

## Expected State

- CRD is registered
- Custom resources can be created and listed
- Custom resource schema is active

## Time Limit

10 minutes
