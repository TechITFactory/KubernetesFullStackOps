#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: inspect-k8s-components.sh
# Lesson: part-2-concepts/2.1-overview/2.1.1-kubernetes-components (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Requires kubectl. Prints kube-system pods (wide), then nodes (wide).
#   2. GET /readyz?verbose (preferred health signal); warns if unreachable.
#
# Exit: 0; 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

echo "[INFO] Control-plane and addon pods:"
kubectl get pods -n kube-system -o wide

echo
echo "[INFO] Nodes:"
kubectl get nodes -o wide

echo
echo "[INFO] Component status via readyz/livez is preferred over deprecated componentstatuses."
kubectl get --raw /readyz?verbose 2>/dev/null || echo "[WARN] Unable to query /readyz on current cluster."
