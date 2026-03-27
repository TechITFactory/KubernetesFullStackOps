#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-stateless-lab}"
APP_NAME="${APP_NAME:-nginx-demo}"
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
kubectl apply -f "$YAMLS_DIR/00-namespace.yaml"

echo "==> Applying Deployment (v1)..."
kubectl apply -f "$YAMLS_DIR/01-nginx-deployment.yaml"

echo "==> Applying Service..."
kubectl apply -f "$YAMLS_DIR/02-nginx-service.yaml"

echo "==> Waiting for rollout to complete..."
kubectl rollout status deployment/"$APP_NAME" -n "$NAMESPACE" --timeout=120s

echo ""
echo "==> Deployment:"
kubectl get deployment "$APP_NAME" -n "$NAMESPACE"

echo ""
echo "==> Pods:"
kubectl get pods -n "$NAMESPACE" -l "app=$APP_NAME"

echo ""
echo "==> Service:"
kubectl get service "$APP_NAME" -n "$NAMESPACE"

echo ""
echo "Stateless app is running."
echo "Next: run rolling-update.sh to push a zero-downtime version update."
