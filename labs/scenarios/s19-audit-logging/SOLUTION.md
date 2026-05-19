# s19: Audit Logging — Solution

## Diagnosis

```bash
docker exec <cluster>-control-plane cat /etc/kubernetes/audit-policy.yaml
docker exec <cluster>-control-plane grep audit /etc/kubernetes/manifests/kube-apiserver.yaml
```

## Fix

**Create audit policy:**
```bash
docker exec <cluster>-control-plane bash -c 'cat > /etc/kubernetes/audit-policy.yaml' << 'AUDITEOF'
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: RequestResponse
  omitStages:
  - RequestReceived
AUDITEOF

docker exec <cluster>-control-plane systemctl restart kubelet
```

## Why

API server needs audit policy. Missing = no logging.
