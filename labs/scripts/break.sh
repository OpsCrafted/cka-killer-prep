#!/bin/bash
set -euo pipefail

LAB="${1:-}"
CLUSTER_NAME="${2:-cka-lab}"

if [ -z "$LAB" ]; then
  echo "Usage: ./break.sh <lab-name> [cluster-name]"
  echo ""
  echo "Available labs:"
  echo "  lab-01-node-not-ready        Kubelet stopped on a worker node"
  echo "  lab-02-broken-service        Service selector mismatch — no endpoints"
  echo "  lab-03-crashloop             Pod in CrashLoopBackOff — wrong command"
  echo "  lab-04-scheduler-down        Scheduler static pod removed"
  echo "  lab-05-certificate-expired   API server cert replaced with expired one"
  echo "  lab-06-network-policy        Pods can't communicate — restrictive policy"
  echo "  lab-07-pvc-pending           PVC stuck in Pending — size mismatch"
  echo "  lab-08-rbac-denied           ServiceAccount missing permissions"
  echo "  lab-09-etcd-restore          Cluster state corrupted — restore from backup"
  echo "  lab-10-kubelet-misconfigured Kubelet config path is wrong"
  exit 0
fi

CP_CONTAINER="$CLUSTER_NAME-control-plane"
W1_CONTAINER="$CLUSTER_NAME-worker"
W2_CONTAINER="$CLUSTER_NAME-worker2"

echo "═══════════════════════════════════════════════"
echo "  Breaking: $LAB"
echo "═══════════════════════════════════════════════"

case "$LAB" in

  lab-01-node-not-ready)
    echo "Stopping kubelet on worker node..."
    docker exec "$W1_CONTAINER" systemctl stop kubelet
    echo ""
    echo "SCENARIO: One of your worker nodes has gone NotReady."
    echo "TASK: Find the affected node, SSH into it (docker exec -it $W1_CONTAINER bash),"
    echo "      diagnose why it's NotReady, and fix it."
    echo "EXPECTED: All nodes should be Ready."
    ;;

  lab-02-broken-service)
    echo "Creating deployment and misconfigured service..."
    kubectl --context "kind-$CLUSTER_NAME" create namespace lab02 2>/dev/null || true
    kubectl --context "kind-$CLUSTER_NAME" -n lab02 create deployment web --image=nginx:1.24 --replicas=2
    kubectl --context "kind-$CLUSTER_NAME" -n lab02 wait --for=condition=available deployment/web --timeout=60s
    # Create service with WRONG selector
    kubectl --context "kind-$CLUSTER_NAME" apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: lab02
spec:
  selector:
    app: web-frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
    echo ""
    echo "SCENARIO: A deployment 'web' in namespace 'lab02' has 2 running pods."
    echo "          A service 'web-svc' exists but returns no results when curled."
    echo "TASK: Diagnose why the service has no endpoints and fix it."
    echo "EXPECTED: 'kubectl get endpoints web-svc -n lab02' shows pod IPs."
    ;;

  lab-03-crashloop)
    echo "Creating pod with wrong command..."
    kubectl --context "kind-$CLUSTER_NAME" create namespace lab03 2>/dev/null || true
    kubectl --context "kind-$CLUSTER_NAME" apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: app-server
  namespace: lab03
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["/bin/sh", "-c", "cat /config/app.conf && sleep 3600"]
EOF
    echo ""
    echo "SCENARIO: Pod 'app-server' in namespace 'lab03' is in CrashLoopBackOff."
    echo "TASK: Find out why, and fix the pod so it runs successfully."
    echo "HINT: The pod expects a config file that doesn't exist."
    echo "EXPECTED: Pod is Running and stays Running."
    ;;

  lab-04-scheduler-down)
    echo "Removing kube-scheduler static pod manifest..."
    docker exec "$CP_CONTAINER" mv /etc/kubernetes/manifests/kube-scheduler.yaml /etc/kubernetes/kube-scheduler.yaml.bak
    sleep 5
    echo ""
    echo "SCENARIO: New pods are stuck in Pending state. Something is wrong with scheduling."
    echo "TASK: Diagnose why pods aren't being scheduled and fix it."
    echo "TEST: Run 'kubectl run test-sched --image=nginx' — it should become Running."
    echo "EXPECTED: The scheduler is running and new pods get scheduled."
    ;;

  lab-05-certificate-expired)
    echo "This lab requires manual cert manipulation. Setting up the scenario..."
    # Create a namespace and deployment that will break when apiserver restarts
    kubectl --context "kind-$CLUSTER_NAME" create namespace lab05 2>/dev/null || true
    kubectl --context "kind-$CLUSTER_NAME" -n lab05 create deployment critical-app --image=nginx --replicas=1
    echo ""
    echo "SCENARIO: You suspect the API server certificate may expire soon."
    echo "TASK:"
    echo "  1. SSH into the control plane: docker exec -it $CP_CONTAINER bash"
    echo "  2. Check when the apiserver cert expires using openssl"
    echo "  3. Check all cert expiry dates using kubeadm"
    echo "  4. Write the apiserver cert expiry date to /tmp/cert-expiry.txt"
    echo "  5. Write the command to renew it to /tmp/renew-cert.sh"
    echo "EXPECTED: Correct expiry date and correct kubeadm renew command."
    ;;

  lab-06-network-policy)
    echo "Creating pods and restrictive network policy..."
    kubectl --context "kind-$CLUSTER_NAME" create namespace lab06 2>/dev/null || true
    kubectl --context "kind-$CLUSTER_NAME" -n lab06 run frontend --image=nginx --labels="role=frontend"
    kubectl --context "kind-$CLUSTER_NAME" -n lab06 run backend --image=nginx --labels="role=backend"
    kubectl --context "kind-$CLUSTER_NAME" -n lab06 run database --image=nginx --labels="role=database"
    kubectl --context "kind-$CLUSTER_NAME" -n lab06 wait --for=condition=ready pod/frontend pod/backend pod/database --timeout=60s
    # Deny all ingress to backend
    kubectl --context "kind-$CLUSTER_NAME" apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-backend
  namespace: lab06
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
EOF
    echo ""
    echo "SCENARIO: Namespace 'lab06' has frontend, backend, and database pods."
    echo "          A NetworkPolicy blocks ALL ingress to the backend pod."
    echo "TASK: Modify the NetworkPolicy to allow traffic from frontend to backend"
    echo "      on port 80, while still blocking all other ingress."
    echo "EXPECTED: frontend can reach backend:80, database cannot reach backend."
    ;;

  lab-07-pvc-pending)
    echo "Creating PV and mismatched PVC..."
    kubectl --context "kind-$CLUSTER_NAME" create namespace lab07 2>/dev/null || true
    kubectl --context "kind-$CLUSTER_NAME" apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: lab07-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/lab07
  persistentVolumeReclaimPolicy: Retain
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lab07-pvc
  namespace: lab07
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: ""
EOF
    echo ""
    echo "SCENARIO: PVC 'lab07-pvc' in namespace 'lab07' is stuck in Pending."
    echo "          A PV 'lab07-pv' exists but isn't binding."
    echo "TASK: Diagnose why the PVC won't bind and fix it."
    echo "EXPECTED: PVC status is Bound."
    ;;

  lab-08-rbac-denied)
    echo "Creating ServiceAccount with insufficient permissions..."
    kubectl --context "kind-$CLUSTER_NAME" create namespace lab08 2>/dev/null || true
    kubectl --context "kind-$CLUSTER_NAME" -n lab08 create serviceaccount app-deployer
    kubectl --context "kind-$CLUSTER_NAME" -n lab08 create role pod-reader --verb=get,list --resource=pods
    kubectl --context "kind-$CLUSTER_NAME" -n lab08 create rolebinding app-deployer-binding --role=pod-reader --serviceaccount=lab08:app-deployer
    echo ""
    echo "SCENARIO: ServiceAccount 'app-deployer' in namespace 'lab08' needs to"
    echo "          create and delete Deployments, but currently can only read Pods."
    echo "TASK: Fix the RBAC so app-deployer can create and delete Deployments."
    echo "VERIFY: kubectl auth can-i create deployments --as=system:serviceaccount:lab08:app-deployer -n lab08"
    echo "EXPECTED: 'yes'"
    ;;

  lab-09-etcd-restore)
    echo "Creating a pre-backup state and taking a snapshot..."
    kubectl --context "kind-$CLUSTER_NAME" create namespace lab09-before-backup 2>/dev/null || true
    kubectl --context "kind-$CLUSTER_NAME" -n lab09-before-backup create deployment old-app --image=nginx --replicas=1
    # Take etcd backup
    docker exec "$CP_CONTAINER" sh -c 'ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
      --cacert=/etc/kubernetes/pki/etcd/ca.crt \
      --cert=/etc/kubernetes/pki/etcd/server.crt \
      --key=/etc/kubernetes/pki/etcd/server.key 2>/dev/null'
    # Create post-backup state (this should disappear after restore)
    kubectl --context "kind-$CLUSTER_NAME" create namespace lab09-after-backup 2>/dev/null || true
    kubectl --context "kind-$CLUSTER_NAME" -n lab09-after-backup create deployment new-app --image=nginx --replicas=1
    echo ""
    echo "SCENARIO: An etcd backup was taken at /tmp/etcd-backup.db on the control plane."
    echo "          After the backup, namespace 'lab09-after-backup' was created."
    echo "TASK: Restore etcd from the backup. After restore, 'lab09-after-backup'"
    echo "      should no longer exist, but 'lab09-before-backup' should."
    echo "SSH: docker exec -it $CP_CONTAINER bash"
    echo "EXPECTED: lab09-before-backup exists, lab09-after-backup does not."
    ;;

  lab-10-kubelet-misconfigured)
    echo "Misconfiguring kubelet on worker node..."
    # Change the kubelet config to point to wrong path
    docker exec "$W2_CONTAINER" sh -c 'sed -i "s|/var/lib/kubelet/config.yaml|/var/lib/kubelet/wrong-config.yaml|g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf'
    docker exec "$W2_CONTAINER" systemctl daemon-reload
    docker exec "$W2_CONTAINER" systemctl restart kubelet
    sleep 3
    echo ""
    echo "SCENARIO: Node '$W2_CONTAINER' has gone NotReady after a config change."
    echo "TASK: SSH into the node (docker exec -it $W2_CONTAINER bash),"
    echo "      find the kubelet configuration error, and fix it."
    echo "EXPECTED: All nodes are Ready."
    ;;

  *)
    echo "ERROR: Unknown lab '$LAB'"
    echo "Run ./break.sh without arguments to see available labs."
    exit 1
    ;;
esac

echo ""
echo "═══════════════════════════════════════════════"
echo "  💥 Lab is active. Go fix it!"
echo "  When done: ./verify.sh $LAB"
echo "═══════════════════════════════════════════════"
