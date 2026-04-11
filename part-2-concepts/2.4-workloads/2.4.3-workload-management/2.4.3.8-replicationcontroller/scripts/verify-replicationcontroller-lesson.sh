#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-replicationcontroller-lesson.sh
# Lesson: 2.4.3.8 ReplicationController
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Checks ReplicationController rc-demo (NS default: default).
#   2. Confirms status.replicas and status.readyReplicas match spec.replicas.
#
# Prerequisite: kubectl apply -f yamls/replicationcontroller-demo.yaml
# Exit: 0 on success.
# ------------------------------------------------------------------------------
set -euo pipefail

NS="${NS:-default}"
RC="rc-demo"

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

if ! kubectl -n "$NS" get rc "$RC" &>/dev/null; then
  echo "FAIL: ReplicationController $NS/$RC not found. Run: kubectl apply -f yamls/replicationcontroller-demo.yaml" >&2
  exit 1
fi

want=$(kubectl -n "$NS" get rc "$RC" -o jsonpath='{.spec.replicas}')
have=$(kubectl -n "$NS" get rc "$RC" -o jsonpath='{.status.replicas}')
ready=$(kubectl -n "$NS" get rc "$RC" -o jsonpath='{.status.readyReplicas}')

have="${have:-0}"
ready="${ready:-0}"

if [[ "$have" != "$want" ]] || [[ "$ready" != "$want" ]]; then
  echo "FAIL: want replicas=$want status.replicas=$have readyReplicas=$ready" >&2
  kubectl -n "$NS" get pods -l app="$RC" -o wide >&2
  exit 1
fi

echo "verify-replicationcontroller-lesson: OK ($NS/$RC replicas=$want ready=$ready)"
