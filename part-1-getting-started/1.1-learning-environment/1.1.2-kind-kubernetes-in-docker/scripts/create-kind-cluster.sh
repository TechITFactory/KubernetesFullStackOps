#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-kfsops-kind}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="${CONFIG_PATH:-$SCRIPT_DIR/../yamls/kind-cluster-config.yaml}"

command -v kind >/dev/null 2>&1 || {
  echo "kind was not found in PATH. Run install-kind.sh first." >&2
  exit 1
}

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

command -v docker >/dev/null 2>&1 || {
  echo "docker was not found in PATH. Kind requires Docker." >&2
  exit 1
}

if kind get clusters 2>/dev/null | grep -Fxq "$CLUSTER_NAME"; then
  echo "Kind cluster '$CLUSTER_NAME' already exists. Reusing it."
else
  kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_PATH"
fi

kubectl cluster-info --context "kind-${CLUSTER_NAME}"
kubectl get nodes --context "kind-${CLUSTER_NAME}"

echo "Kind cluster is ready."
echo "Apply sample workload with: kubectl apply -f ../yamls/sample-workload.yaml"
