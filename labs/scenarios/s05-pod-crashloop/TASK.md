# Scenario s05: Pod Stuck in CrashLoopBackOff

## Problem

A deployment's pods are restarting every few seconds (CrashLoopBackOff). The app needs a config file to start.

Create the missing config and fix the deployment.

## Expected State

- Pods are Running (not CrashLoopBackOff)
- Container stays alive for > 60 seconds
- ConfigMap with app config exists

## Time Limit

15 minutes
