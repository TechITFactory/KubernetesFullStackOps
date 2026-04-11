#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: kubectl-essentials.sh
# Lesson: part-2-concepts/2.1-overview/2.1.4-the-kubectl-command-line-tool (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Prints current context, namespaces, first 20 api-resources, custom-columns node table.
#
# Exit: 0; 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

echo "[INFO] Current context:"
kubectl config current-context

echo
echo "[INFO] Namespaces:"
kubectl get ns

echo
echo "[INFO] API resources:"
kubectl api-resources | head -n 20

echo
echo "[INFO] Example custom output:"
kubectl get nodes -o custom-columns=NAME:.metadata.name,OS:.status.nodeInfo.osImage,KERNEL:.status.nodeInfo.kernelVersion
