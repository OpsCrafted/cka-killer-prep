# Scenario s07: API Server TLS Certificate Expired

## Problem

Cluster components can't communicate. Logs show "certificate has expired". The API server TLS cert is past expiration.

Check certificate status and renew if needed.

## Expected State

- Certificate is not expired (check expiration date)
- API server is responsive
- kubectl commands work
- All nodes report Ready

## Time Limit

15 minutes
