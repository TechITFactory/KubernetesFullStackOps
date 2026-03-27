#!/usr/bin/env bash
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
