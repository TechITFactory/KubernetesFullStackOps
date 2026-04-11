#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-2-4-workloads-module.sh
# Module: part-2-concepts/2.4-workloads
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Runs cluster smoke: API reachability + sample workload listing.
#   2. Optionally runs lesson verifies for demos you already applied (no apply).
#
# Usage:
#   bash scripts/verify-2-4-workloads-module.sh           # smoke only
#   bash scripts/verify-2-4-workloads-module.sh --labs    # smoke + core workload demos; includes Job TTL wait (~1–3 min)
#
# Run from: part-2-concepts/2.4-workloads/
# Exit: 0 if smoke passes; lesson verifies may fail if you have not applied those YAMLs.
# ------------------------------------------------------------------------------
set -euo pipefail

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

echo "==> cluster / workload smoke"
kubectl cluster-info >/dev/null
kubectl get --raw /readyz >/dev/null
kubectl get deploy,sts,ds,job,cronjob -A 2>/dev/null | head -n 25 || true
kubectl get pods -A 2>/dev/null | head -n 20 || true

echo "verify-2-4-workloads-module: smoke OK"

if [[ "${1:-}" == "--labs" ]]; then
  echo ""
  echo "==> lesson verifies (expect failures until you apply each lesson YAML)"
  bash "$ROOT/2.4.1-pods/2.4.1.1-pod-lifecycle/scripts/verify-pod-lifecycle-lesson.sh" || true
  bash "$ROOT/2.4.3-workload-management/2.4.3.1-deployments/scripts/verify-deployments-lesson.sh" || true
  bash "$ROOT/2.4.3-workload-management/2.4.3.2-replicaset/scripts/verify-replicaset-lesson.sh" || true
  bash "$ROOT/2.4.3-workload-management/2.4.3.3-statefulsets/scripts/verify-statefulset-lesson.sh" || true
  bash "$ROOT/2.4.3-workload-management/2.4.3.4-daemonset/scripts/verify-daemonset-lesson.sh" || true
  bash "$ROOT/2.4.3-workload-management/2.4.3.5-jobs/scripts/verify-jobs-lesson.sh" || true
  bash "$ROOT/2.4.3-workload-management/2.4.3.6-automatic-cleanup-for-finished-jobs/scripts/verify-job-ttl-lesson.sh" || true
  bash "$ROOT/2.4.3-workload-management/2.4.3.7-cronjob/scripts/verify-cronjob-lesson.sh" || true
  bash "$ROOT/2.4.3-workload-management/2.4.3.8-replicationcontroller/scripts/verify-replicationcontroller-lesson.sh" || true
  bash "$ROOT/2.4.4-managing-workloads/scripts/verify-manage-workloads-lesson.sh" || true
fi
