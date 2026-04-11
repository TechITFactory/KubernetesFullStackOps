#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-replicaset-lesson.sh
# Lesson: 2.4.3.2 ReplicaSet
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Checks ReplicaSet replicaset-demo in NS (default: default).
#   2. Confirms fullyLabeledReplicas and readyReplicas match spec (2).
#
# Prerequisite: kubectl apply -f yamls/replicaset-demo.yaml
# Exit: 0 on success.
# ------------------------------------------------------------------------------
set -euo pipefail

NS="${NS:-default}"
RS="replicaset-demo"

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

if ! kubectl -n "$NS" get rs "$RS" &>/dev/null; then
  echo "FAIL: ReplicaSet $NS/$RS not found. Run: kubectl apply -f yamls/replicaset-demo.yaml" >&2
  exit 1
fi

want=$(kubectl -n "$NS" get rs "$RS" -o jsonpath='{.spec.replicas}')
have=$(kubectl -n "$NS" get rs "$RS" -o jsonpath='{.status.replicas}')
ready=$(kubectl -n "$NS" get rs "$RS" -o jsonpath='{.status.readyReplicas}')

have="${have:-0}"
ready="${ready:-0}"

if [[ "$have" != "$want" ]] || [[ "$ready" != "$want" ]]; then
  echo "FAIL: want replicas=$want status.replicas=$have readyReplicas=$ready" >&2
  kubectl -n "$NS" get pods -l app="$RS" -o wide >&2
  exit 1
fi

echo "verify-replicaset-lesson: OK ($NS/$RS replicas=$want ready=$ready)"
