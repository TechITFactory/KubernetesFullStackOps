#!/usr/bin/env bash
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

echo "[INFO] API groups:"
kubectl api-versions

echo
echo "[INFO] API resources:"
kubectl api-resources

echo
echo "[INFO] Root API discovery:"
kubectl get --raw /
