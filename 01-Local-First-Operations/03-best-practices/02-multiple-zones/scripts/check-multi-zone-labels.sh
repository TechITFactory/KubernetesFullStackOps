#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: check-multi-zone-labels.sh
# Lesson: 02-running-in-multiple-zones (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Requires kubectl. Lists nodes with topology.kubernetes.io/region and zone columns.
#   2. Parses jsonpath for zone label; exits 1 if any node has empty zone (prints node names).
#
# Exit: 0 if every node has a zone label; 1 if any missing or kubectl absent.
# ------------------------------------------------------------------------------
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
