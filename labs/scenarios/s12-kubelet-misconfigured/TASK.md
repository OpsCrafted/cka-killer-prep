# Scenario s12: Kubelet Misconfigured

## Problem

Node is showing errors and can't run pods. Kubelet is misconfigured—its --config flag points to a non-existent file.

Fix the kubelet configuration and restart the service.

## Expected State

- Kubelet is Running
- Node is Ready
- Pods can schedule on node
- kubelet logs show no errors

## Time Limit

15 minutes
