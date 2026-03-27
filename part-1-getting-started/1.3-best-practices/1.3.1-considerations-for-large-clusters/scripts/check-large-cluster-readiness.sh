#!/usr/bin/env bash
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
