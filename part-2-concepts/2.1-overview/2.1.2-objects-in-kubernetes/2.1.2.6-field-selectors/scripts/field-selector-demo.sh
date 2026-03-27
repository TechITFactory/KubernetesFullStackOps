#!/usr/bin/env bash
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

kubectl get pods -A --field-selector=status.phase=Running
echo
kubectl get events -A --field-selector=type=Warning
