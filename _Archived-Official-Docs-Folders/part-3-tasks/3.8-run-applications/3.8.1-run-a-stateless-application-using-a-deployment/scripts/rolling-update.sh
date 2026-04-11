#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-stateless-lab}"
APP_NAME="${APP_NAME:-nginx-demo}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YAMLS_DIR="$SCRIPT_DIR/../yamls"
TARGET_IMAGE="nginx:1.28"

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

kubectl cluster-info >/dev/null 2>&1 || {
  echo "Cannot reach a Kubernetes cluster. Check your kubeconfig." >&2
  exit 1
}

CURRENT_IMAGE="$(kubectl get deployment "$APP_NAME" -n "$NAMESPACE" \
  -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || echo "")"

if [[ "$CURRENT_IMAGE" == "$TARGET_IMAGE" ]]; then
  echo "Deployment '$APP_NAME' is already running '$TARGET_IMAGE'. Nothing to update."
  kubectl rollout status deployment/"$APP_NAME" -n "$NAMESPACE"
  exit 0
fi

echo "==> Current image : ${CURRENT_IMAGE:-<not deployed>}"
echo "==> Target image  : $TARGET_IMAGE"
echo "==> Applying v2 manifest..."
kubectl apply -f "$YAMLS_DIR/03-nginx-deployment-v2.yaml"

echo "==> Watching rolling update..."
kubectl rollout status deployment/"$APP_NAME" -n "$NAMESPACE" --timeout=120s

echo ""
echo "==> Rollout history:"
kubectl rollout history deployment/"$APP_NAME" -n "$NAMESPACE"

echo ""
echo "==> Pods after update:"
kubectl get pods -n "$NAMESPACE" -l "app=$APP_NAME"

echo ""
echo "Rolling update complete. Zero downtime maintained via maxUnavailable=0."
echo "To rollback: kubectl rollout undo deployment/$APP_NAME -n $NAMESPACE"
