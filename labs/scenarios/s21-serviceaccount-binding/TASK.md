# Scenario s21: ServiceAccount binding - cross-namespace access

## Problem
ServiceAccount in one namespace needs to access resources in another. RoleBinding is missing or misconfigured.

## Expected State
- ServiceAccount can access cross-namespace resources
- RoleBinding grants correct permissions
- Tests confirm resource access works

## Time Limit
10 minutes
