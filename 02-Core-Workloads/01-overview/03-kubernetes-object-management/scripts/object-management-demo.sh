#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: object-management-demo.sh
# Lesson: 2.1.2.1-kubernetes-object-management (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. kubectl apply object-management-demo.yaml (namespace + workload).
#   2. kubectl get deploy,pods in namespace object-management-demo.
#
# Exit: kubectl exit codes; 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${MANIFEST:-$SCRIPT_DIR/../yamls/object-management-demo.yaml}"

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

kubectl apply -f "$MANIFEST"
kubectl get deploy,pods -n object-management-demo
