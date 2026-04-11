#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-1-3-module-readiness.sh
# Lesson: 01-Local-First-Operations/03-best-practices (module README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Confirms kubectl works and cluster is reachable (cluster-info, nodes, /readyz).
#   2. Read-only — does not apply quotas, PSS labels, or PKI checks (those are per-lesson).
#
# Run per-lesson scripts from each 03.x folder when you finish that lesson (some need
# root or specific cluster features — see each README).
#
# Exit: 0 on success; 1 if kubectl missing or API unreachable.
# ------------------------------------------------------------------------------
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || {
  echo "FAIL: kubectl not in PATH." >&2
  exit 1
}

echo "==> cluster-info"
kubectl cluster-info

echo ""
echo "==> /readyz"
kubectl get --raw /readyz >/dev/null
echo "[OK] API readyz"

echo ""
echo "==> nodes"
kubectl get nodes -o wide

echo ""
echo "verify-1-3-module-readiness: OK"
echo "Next: work through 03.1 → 03.5 READMEs and run each lesson's own commands/scripts."
