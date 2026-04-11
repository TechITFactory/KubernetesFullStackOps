#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-part2-prerequisites.sh
# Use:    From any machine with kubectl configured (repo root optional).
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Verifies kubectl exists.
#   2. kubectl cluster-info — proves API server URL resolves.
#   3. kubectl get --raw /readyz — quick API health (empty body OK if 200).
#   4. kubectl get nodes — proves you can read cluster state.
#   5. Prints next-step hint: open part-2-concepts/2.1-overview/README.md
#
# Exit: 0 if all checks pass; 1 if kubectl missing or cluster unreachable.
# ------------------------------------------------------------------------------
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || {
  echo "FAIL: kubectl not in PATH. Finish Part 1 and install kubectl." >&2
  exit 1
}

echo "==> kubectl version (client)"
kubectl version --client --output=yaml 2>/dev/null | head -n 8 || kubectl version --client

echo ""
echo "==> cluster-info"
kubectl cluster-info

echo ""
echo "==> API /readyz"
if kubectl get --raw /readyz >/dev/null 2>&1; then
  echo "[OK] /readyz returned success"
else
  echo "[WARN] /readyz not reachable — check context, firewall, or RBAC" >&2
  exit 1
fi

echo ""
echo "==> nodes"
kubectl get nodes -o wide

echo ""
echo "verify-part2-prerequisites: OK — you may start Part 2 with 2.1 Overview."
echo "Open: part-2-concepts/2.1-overview/README.md"
