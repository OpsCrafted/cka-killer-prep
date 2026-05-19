# s16: CNI Migration — Solution

## Diagnosis

```bash
kubectl get pods -n kube-system -l k8s-app=kube-proxy
kubectl describe node <node>
```

## Fix

**Install new CNI:**
```bash
kubectl apply -f <new-cni-manifest>
```

**Remove old CNI:**
```bash
kubectl delete daemonset -n kube-system <old-cni>
kubectl delete configmap -n kube-system <old-config>
```

**Verify:**
```bash
kubectl get pods -n kube-system
```

## Why

Cluster needs CNI plugin for pod networking. Switching requires both install+delete.
