#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: check-large-cluster-readiness.sh
# Lesson: 03.1-considerations-for-large-clusters (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Requires kubectl. Counts nodes and pods cluster-wide; warns if fewer than 3 nodes.
#   2. Probes list PriorityClasses, PDBs, and GET /readyz — warns on failure (RBAC or connectivity).
#   3. kubectl get nodes with topology zone/region columns — read-only inspection.
#
# Exit: 0 (warnings only); exits 1 only if kubectl missing at start.
# ------------------------------------------------------------------------------
set -euo pipefail

warn() {
  echo "[WARN] $*"
}

info() {
  echo "[INFO] $*"
}

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

NODE_COUNT="$(kubectl get nodes --no-headers 2>/dev/null | wc -l | awk '{print $1}')"
POD_COUNT="$(kubectl get pods -A --no-headers 2>/dev/null | wc -l | awk '{print $1}')"

info "Nodes detected: ${NODE_COUNT}"
info "Pods detected: ${POD_COUNT}"

if [[ "${NODE_COUNT}" -lt 3 ]]; then
  warn "Fewer than 3 nodes detected. Multi-node behavior and spread validation may not be meaningful yet."
fi

kubectl get priorityclasses >/dev/null 2>&1 || warn "Unable to list PriorityClasses."
kubectl get pdb -A >/dev/null 2>&1 || warn "Unable to list PodDisruptionBudgets."
kubectl get --raw /readyz >/dev/null 2>&1 || warn "API server /readyz endpoint not reachable through current context."

echo "[INFO] Topology labels present on nodes:"
kubectl get nodes -L topology.kubernetes.io/zone,topology.kubernetes.io/region

echo "[INFO] Readiness check completed."
