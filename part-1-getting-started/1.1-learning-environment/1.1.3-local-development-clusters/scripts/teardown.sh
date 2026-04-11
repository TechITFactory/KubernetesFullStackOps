#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: teardown.sh (dev-local namespace)
# Lesson: 1.1.3-local-development-clusters (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Requires kubectl. If namespace NAMESPACE (default dev-local) exists → kubectl delete namespace
#      (cascades all resources in that namespace). Else prints nothing to do.
#
# Exit: 0; non-zero on delete failure.
# ------------------------------------------------------------------------------
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
