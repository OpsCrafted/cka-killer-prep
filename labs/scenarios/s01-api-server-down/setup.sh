#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Wait for API server to be responsive
for i in {1..30}; do
  kubectl get nodes &>/dev/null && break
  sleep 1
done

# Install CNI if not already present
if ! kubectl get ns kube-flannel &>/dev/null 2>&1; then
  kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
  kubectl rollout status daemonset/kube-flannel-ds -n kube-flannel --timeout=120s || true
fi

# Wait for nodes to be Ready
kubectl wait --for=condition=Ready nodes --all --timeout=120s || true

# Deploy baseline app
kubectl apply -f "$SCENARIO_DIR/manifests/deployment.yaml"
kubectl rollout status deployment/demo-app --timeout=60s || true

# Break: corrupt etcd-servers port in kube-apiserver manifest (2379 → 2380)
docker exec "${CLUSTER_NAME}-control-plane" \
  sed -i 's|--etcd-servers=https://127.0.0.1:2379|--etcd-servers=https://127.0.0.1:2380|g' \
  /etc/kubernetes/manifests/kube-apiserver.yaml

# Wait for API server to go down
echo "Waiting for API server to go down..."
for i in {1..30}; do
  kubectl get nodes &>/dev/null || break
  sleep 1
done

echo "✓ Scenario setup complete"
