#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$SCENARIO_DIR/manifests/deployment.yaml"
sleep 3

# Misconfigure kubelet: point config to wrong path
docker exec "$CLUSTER_NAME-worker" sh -c 'sed -i "s|--config=.*|--config=/etc/kubernetes/kubelet/wrong-config.yaml|" /etc/sysconfig/kubelet || sed -i "s|--config=.*|--config=/etc/kubernetes/kubelet/wrong-config.yaml|" /etc/default/kubelet' || true

# Restart kubelet to apply bad config
docker exec "$CLUSTER_NAME-worker" systemctl restart kubelet || true

sleep 5

echo "✓ Scenario setup complete: Kubelet misconfigured"
