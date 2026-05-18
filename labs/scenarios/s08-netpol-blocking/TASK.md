# Scenario s08: NetworkPolicy Blocks Pod Communication

## Problem

Pods can't reach each other. NetworkPolicy is too restrictive—it blocks all traffic by default.

Add a NetworkPolicy that allows the required pod-to-pod communication.

## Expected State

- Pods can communicate (curl between pods works)
- NetworkPolicy allows ingress from same namespace
- No traffic denied logs in events

## Time Limit

15 minutes
