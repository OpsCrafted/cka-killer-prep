# Scenario s27: DNS debugging - broken DNS in pods

## Problem
Pod DNS resolution is failing. CoreDNS may be misconfigured or pods can't reach it.

## Expected State
- Pods can resolve service names
- DNS queries work within cluster
- CoreDNS running and healthy

## Time Limit
10 minutes
