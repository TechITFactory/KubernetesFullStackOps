#!/usr/bin/env bash
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

echo "[INFO] Node zone labels:"
kubectl get nodes -L topology.kubernetes.io/region,topology.kubernetes.io/zone

MISSING="$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"|"}{.metadata.labels.topology\.kubernetes\.io/zone}{"\n"}{end}' | awk -F'|' '$2 == "" {print $1}')"

if [[ -n "$MISSING" ]]; then
  echo "[WARN] The following nodes are missing topology.kubernetes.io/zone labels:"
  echo "$MISSING"
  exit 1
fi

echo "[INFO] All nodes expose zone labels."
