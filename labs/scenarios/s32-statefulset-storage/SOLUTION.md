# s32: StatefulSet Storage — Solution

## Diagnosis

Check StatefulSet status:
```bash
kubectl get statefulset db -n stateful-test
# Shows: 3 desired but 0 ready (pods failing to start)

kubectl describe statefulset db -n stateful-test
# Error: serviceName "db" does not exist

kubectl get pods -n stateful-test
# Pods stuck in Pending (waiting for service)
```

Check if headless service exists:
```bash
kubectl get service db -n stateful-test
# Not found - this is the problem!
```

## Fix

Create headless service (clusterIP: None) matching StatefulSet serviceName:
```bash
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: db
  namespace: stateful-test
spec:
  clusterIP: None
  selector:
    app: db
  ports:
  - port: 5432
    targetPort: 5432
EOF
```

Verify pods now start:
```bash
kubectl get pods -n stateful-test
# Should show: db-0, db-1, db-2 all Running

kubectl get service db -n stateful-test
# CLUSTER-IP: None (headless)
```

## Why

StatefulSet requires headless service for:
1. Stable DNS names (db-0.db, db-1.db, db-2.db)
2. Persistent pod identity across restarts
3. Ordered pod creation/termination

Without headless service, pods can't reach stable identities and remain Pending.

## Key Points

- serviceName in StatefulSet must match Service name
- Service must have clusterIP: None (headless)
- Headless service provides stable DNS, not load balancing
