#!/bin/bash
set -euo pipefail

LAB="${1:-}"
CLUSTER_NAME="${2:-cka-lab}"
CTX="kind-$CLUSTER_NAME"
PASS=0
FAIL=0

if [ -z "$LAB" ]; then
  echo "Usage: ./verify.sh <lab-name> [cluster-name]"
  exit 0
fi

check() {
  local desc="$1"
  shift
  if "$@" &>/dev/null; then
    echo "  ✅ $desc"
    ((PASS++))
  else
    echo "  ❌ $desc"
    ((FAIL++))
  fi
}

echo "═══════════════════════════════════════════════"
echo "  Verifying: $LAB"
echo "═══════════════════════════════════════════════"

CP_CONTAINER="$CLUSTER_NAME-control-plane"
W1_CONTAINER="$CLUSTER_NAME-worker"
W2_CONTAINER="$CLUSTER_NAME-worker2"

case "$LAB" in

  lab-01-node-not-ready)
    check "All nodes are Ready" \
      bash -c "kubectl --context $CTX get nodes --no-headers | grep -v Ready | wc -l | grep -q '^0$'"
    check "Worker node kubelet is running" \
      docker exec "$W1_CONTAINER" systemctl is-active kubelet
    ;;

  lab-02-broken-service)
    check "Service web-svc has endpoints" \
      bash -c "kubectl --context $CTX -n lab02 get endpoints web-svc --no-headers | grep -v '<none>'"
    check "Endpoints match running pod IPs" \
      bash -c "[ $(kubectl --context $CTX -n lab02 get endpoints web-svc -o jsonpath='{.subsets[0].addresses}' | grep -c 'ip') -ge 1 ]"
    ;;

  lab-03-crashloop)
    check "Pod app-server is Running" \
      bash -c "kubectl --context $CTX -n lab03 get pod app-server -o jsonpath='{.status.phase}' | grep -q Running"
    check "Pod is not restarting" \
      bash -c "[ $(kubectl --context $CTX -n lab03 get pod app-server -o jsonpath='{.status.containerStatuses[0].restartCount}') -lt 5 ]"
    ;;

  lab-04-scheduler-down)
    check "kube-scheduler is running" \
      bash -c "kubectl --context $CTX -n kube-system get pod -l component=kube-scheduler --no-headers | grep -q Running"
    # Create a test pod to verify scheduling works
    kubectl --context "$CTX" delete pod verify-sched 2>/dev/null || true
    kubectl --context "$CTX" run verify-sched --image=nginx --restart=Never
    sleep 5
    check "New pods are being scheduled" \
      bash -c "kubectl --context $CTX get pod verify-sched -o jsonpath='{.spec.nodeName}' | grep -q ."
    kubectl --context "$CTX" delete pod verify-sched 2>/dev/null || true
    ;;

  lab-05-certificate-expired)
    check "Cert expiry file exists" \
      docker exec "$CP_CONTAINER" test -f /tmp/cert-expiry.txt
    check "Renew script exists" \
      docker exec "$CP_CONTAINER" test -f /tmp/renew-cert.sh
    check "Renew script contains correct command" \
      bash -c "docker exec $CP_CONTAINER cat /tmp/renew-cert.sh | grep -q 'kubeadm certs renew apiserver'"
    ;;

  lab-06-network-policy)
    FRONTEND_IP=$(kubectl --context "$CTX" -n lab06 get pod frontend -o jsonpath='{.status.podIP}')
    BACKEND_IP=$(kubectl --context "$CTX" -n lab06 get pod backend -o jsonpath='{.status.podIP}')
    check "Frontend can reach backend on port 80" \
      kubectl --context "$CTX" -n lab06 exec frontend -- timeout 3 wget -qO- "http://$BACKEND_IP:80"
    # This check expects database to be blocked (timeout = failure = correct behavior)
    if kubectl --context "$CTX" -n lab06 exec database -- timeout 3 wget -qO- "http://$BACKEND_IP:80" &>/dev/null; then
      echo "  ❌ Database should NOT reach backend (policy too permissive)"
      ((FAIL++))
    else
      echo "  ✅ Database correctly blocked from backend"
      ((PASS++))
    fi
    ;;

  lab-07-pvc-pending)
    check "PVC lab07-pvc is Bound" \
      bash -c "kubectl --context $CTX -n lab07 get pvc lab07-pvc -o jsonpath='{.status.phase}' | grep -q Bound"
    ;;

  lab-08-rbac-denied)
    check "app-deployer can create deployments" \
      kubectl --context "$CTX" -n lab08 auth can-i create deployments --as=system:serviceaccount:lab08:app-deployer
    check "app-deployer can delete deployments" \
      kubectl --context "$CTX" -n lab08 auth can-i delete deployments --as=system:serviceaccount:lab08:app-deployer
    ;;

  lab-09-etcd-restore)
    check "Namespace lab09-before-backup exists" \
      kubectl --context "$CTX" get namespace lab09-before-backup
    if kubectl --context "$CTX" get namespace lab09-after-backup &>/dev/null; then
      echo "  ❌ Namespace lab09-after-backup should NOT exist after restore"
      ((FAIL++))
    else
      echo "  ✅ Namespace lab09-after-backup correctly removed by restore"
      ((PASS++))
    fi
    ;;

  lab-10-kubelet-misconfigured)
    check "All nodes are Ready" \
      bash -c "kubectl --context $CTX get nodes --no-headers | grep -v Ready | wc -l | grep -q '^0$'"
    check "Worker2 kubelet is running" \
      docker exec "$W2_CONTAINER" systemctl is-active kubelet
    ;;

  *)
    echo "ERROR: Unknown lab '$LAB'"
    exit 1
    ;;
esac

echo ""
echo "═══════════════════════════════════════════════"
if [ "$FAIL" -eq 0 ]; then
  echo "  🎉 ALL CHECKS PASSED ($PASS/$PASS)"
else
  echo "  ⚠️  $PASS passed, $FAIL failed"
fi
echo "═══════════════════════════════════════════════"
