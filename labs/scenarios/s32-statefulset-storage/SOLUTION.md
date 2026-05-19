# s32: StatefulSet — Solution

## Diagnosis

```bash
kubectl get statefulset
kubectl get pods
```

## Fix

**Create StatefulSet:**
```bash
kubectl apply -f - << 'SSEOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db
spec:
  selector:
    matchLabels:
      app: db
  serviceName: db
  replicas: 3
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: db
        image: postgres:latest
        ports:
        - containerPort: 5432
SSEOF
```

**Create headless service:**
```bash
kubectl apply -f - << 'SVCEOF'
apiVersion: v1
kind: Service
metadata:
  name: db
spec:
  clusterIP: None
  selector:
    app: db
  ports:
  - port: 5432
SVCEOF
```

## Why

StatefulSet provides persistent identity. Pods db-0, db-1, db-2 with stable DNS.
