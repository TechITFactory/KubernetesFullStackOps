#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-dev-local}"

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "==> Deleting namespace '$NAMESPACE' and all resources within it..."
  kubectl delete namespace "$NAMESPACE"
  echo "Teardown complete."
else
  echo "Namespace '$NAMESPACE' does not exist. Nothing to tear down."
fi
