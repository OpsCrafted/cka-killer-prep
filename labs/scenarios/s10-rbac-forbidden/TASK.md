# Scenario s10: ServiceAccount Forbidden (RBAC Denied)

## Problem

A pod is trying to read ConfigMaps but gets "Forbidden" errors (403). The ServiceAccount has no permissions.

Create a Role and RoleBinding to grant the ServiceAccount permission to read ConfigMaps.

## Expected State

- ServiceAccount exists
- Role grants get/list/watch on configmaps
- RoleBinding connects ServiceAccount to Role
- Pod can read ConfigMaps (no more Forbidden)

## Time Limit

15 minutes
