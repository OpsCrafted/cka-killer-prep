# Scenario s30: Multi-tenancy - ingress across namespaces

## Problem
Ingress in one namespace needs to route to services in other namespaces. Multi-tenancy not configured.

## Expected State
- Ingress routing to cross-namespace services
- Service references work
- Traffic reaches services in other namespaces

## Time Limit
15 minutes
