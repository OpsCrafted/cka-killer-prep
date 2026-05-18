# Scenario s28: Service discovery - endpoints registration

## Problem
Service has no endpoints. Pods backing the service aren't registering or selector is wrong.

## Expected State
- Endpoints created for service
- Pods match selector
- Service has ready endpoints

## Time Limit
10 minutes
