#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: ha-prereqs-check.sh
# Lesson: 1.2.2.1.5-options-for-highly-available-topology (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Prints [OK]/[MISSING] for kubectl, kubeadm on PATH.
#   2. Checks env vars CONTROL_PLANE_ENDPOINT and ETCD_ENDPOINTS (expected for HA planning).
#   3. Prints topology reminder text (stacked vs external etcd, LB on 6443) — no cluster changes.
#
# Exit: always 0.
# ------------------------------------------------------------------------------
set -euo pipefail

CONTROL_PLANE_ENDPOINT="${CONTROL_PLANE_ENDPOINT:-}"
ETCD_ENDPOINTS="${ETCD_ENDPOINTS:-}"

check() {
  local label="$1"
  local result="$2"
  if [[ "$result" == "ok" ]]; then
    echo "[OK]      $label"
  else
    echo "[MISSING] $label — $result"
  fi
}

echo "==> HA Prerequisites Check"
echo ""

# kubectl available
if command -v kubectl >/dev/null 2>&1; then
  check "kubectl" "ok"
else
  check "kubectl" "not found in PATH"
fi

# kubeadm available
if command -v kubeadm >/dev/null 2>&1; then
  check "kubeadm" "ok"
else
  check "kubeadm" "not found in PATH"
fi

# Control-plane endpoint configured
if [[ -n "$CONTROL_PLANE_ENDPOINT" ]]; then
  check "CONTROL_PLANE_ENDPOINT ($CONTROL_PLANE_ENDPOINT)" "ok"
else
  check "CONTROL_PLANE_ENDPOINT" "not set — set this to your load balancer address:port"
fi

# etcd endpoints configured (for external etcd topology)
if [[ -n "$ETCD_ENDPOINTS" ]]; then
  check "ETCD_ENDPOINTS ($ETCD_ENDPOINTS)" "ok"
else
  check "ETCD_ENDPOINTS" "not set — required for external etcd topology, optional for stacked"
fi

# Node count hint
echo ""
echo "==> Topology reminder:"
echo "    Stacked etcd HA  : minimum 3 control-plane nodes (each runs etcd + control plane)"
echo "    External etcd HA : minimum 3 control-plane nodes + minimum 3 dedicated etcd nodes"
echo "    Load balancer    : required in both topologies (points to all control-plane nodes on port 6443)"
