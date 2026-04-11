#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: bootstrap-dev-workspace.sh
# Lesson: 03-local-development-clusters (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Requires kubectl and a reachable cluster (kubectl cluster-info).
#   2. kubectl apply: dev-namespace.yaml, resource-quota.yaml, limit-range.yaml, whoami-deployment.yaml
#      from ../yamls/ (namespace NAMESPACE default dev-local).
#   3. kubectl rollout status deployment/whoami in that namespace (60s timeout).
#   4. kubectl get all -n NAMESPACE — shows created objects.
#
# Exit: 0 on success; non-zero if apply or rollout fails.
# ------------------------------------------------------------------------------
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
