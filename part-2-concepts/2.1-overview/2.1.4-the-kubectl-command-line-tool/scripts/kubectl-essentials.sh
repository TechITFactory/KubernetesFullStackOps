#!/usr/bin/env bash
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
