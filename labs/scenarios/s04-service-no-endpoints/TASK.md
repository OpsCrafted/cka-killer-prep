# Scenario s04: Service Has No Endpoints

## Problem

Users report "Connection refused" when accessing a service. kubectl get svc shows the service exists but has no ENDPOINTS.

Fix the service so pods register as endpoints.

## Expected State

- Service has at least 1 endpoint
- Pods behind service are Running
- Service selector matches pod labels

## Time Limit

12 minutes
