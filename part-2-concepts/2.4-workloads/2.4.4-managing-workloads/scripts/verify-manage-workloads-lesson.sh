#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-manage-workloads-lesson.sh
# Lesson: 2.4.4 Managing workloads
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Confirms Deployment manage-workloads-demo exists (default namespace).
#   2. Expects spec.replicas == 3 and availableReplicas after full demo script.
#   3. Expects pod template image nginx:1.27 (after rollback in manage-workloads-demo.sh).
#
# Prerequisite: run ./scripts/manage-workloads-demo.sh end-to-end once.
# Exit: 0 on success.
# ------------------------------------------------------------------------------
set -euo pipefail

NS="${NS:-default}"
DEP="manage-workloads-demo"

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

if ! kubectl -n "$NS" get deploy "$DEP" &>/dev/null; then
  echo "FAIL: Deployment $NS/$DEP not found. Run: ./scripts/manage-workloads-demo.sh" >&2
  exit 1
fi

want=$(kubectl -n "$NS" get deploy "$DEP" -o jsonpath='{.spec.replicas}')
ready=$(kubectl -n "$NS" get deploy "$DEP" -o jsonpath='{.status.readyReplicas}')
avail=$(kubectl -n "$NS" get deploy "$DEP" -o jsonpath='{.status.availableReplicas}')
img=$(kubectl -n "$NS" get deploy "$DEP" -o jsonpath='{.spec.template.spec.containers[0].image}')

ready="${ready:-0}"
avail="${avail:-0}"

if [[ "$want" != "3" ]]; then
  echo "FAIL: expected spec.replicas=3 after demo (got $want). Re-run manage-workloads-demo.sh" >&2
  exit 1
fi
if [[ "$ready" != "$want" ]] || [[ "$avail" != "$want" ]]; then
  echo "FAIL: replicas=$want ready=$ready available=$avail" >&2
  kubectl -n "$NS" get pods -l "app=$DEP" -o wide >&2
  exit 1
fi
if [[ "$img" != *"nginx:1.27"* ]]; then
  echo "FAIL: expected rolled-back image containing nginx:1.27, got: $img" >&2
  exit 1
fi

revs=$(kubectl -n "$NS" rollout history "deployment/$DEP" 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
if [[ "${revs:-0}" -lt 2 ]]; then
  echo "WARN: rollout history shows fewer than 2 revisions — did you skip the image change?" >&2
fi

echo "verify-manage-workloads-lesson: OK ($NS/$DEP replicas=$want image=$img)"
