#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-dev-local}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YAMLS_DIR="$SCRIPT_DIR/../yamls"

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

kubectl cluster-info >/dev/null 2>&1 || {
  echo "Cannot reach a Kubernetes cluster. Check your kubeconfig." >&2
  exit 1
}

echo "==> Applying namespace..."
kubectl apply -f "$YAMLS_DIR/dev-namespace.yaml"

echo "==> Applying ResourceQuota..."
kubectl apply -f "$YAMLS_DIR/resource-quota.yaml"

echo "==> Applying LimitRange..."
kubectl apply -f "$YAMLS_DIR/limit-range.yaml"

echo "==> Applying demo workload..."
kubectl apply -f "$YAMLS_DIR/whoami-deployment.yaml"

echo "==> Waiting for whoami rollout..."
kubectl rollout status deployment/whoami -n "$NAMESPACE" --timeout=60s

echo ""
echo "Development workspace bootstrap complete."
kubectl get all -n "$NAMESPACE"
