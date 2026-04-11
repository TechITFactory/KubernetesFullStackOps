#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-deployments-lesson.sh
# Lesson: 2.4.3.1 Deployments
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Checks Deployment deployment-demo in NS (default: default).
#   2. Waits briefly for Available condition.
#   3. Confirms readyReplicas match spec.replicas (2).
#
# Prerequisite: kubectl apply -f yamls/deployment-demo.yaml
# Exit: 0 on success.
# ------------------------------------------------------------------------------
set -euo pipefail

NS="${NS:-default}"
DEPLOY="deployment-demo"

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

if ! kubectl -n "$NS" get deploy "$DEPLOY" &>/dev/null; then
  echo "FAIL: Deployment $NS/$DEPLOY not found. Run: kubectl apply -f yamls/deployment-demo.yaml" >&2
  exit 1
fi

kubectl -n "$NS" wait --for=condition=available "deploy/$DEPLOY" --timeout=120s

want=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.spec.replicas}')
ready=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.status.readyReplicas}')
avail=$(kubectl -n "$NS" get deploy "$DEPLOY" -o jsonpath='{.status.availableReplicas}')

if [[ "$ready" != "$want" ]] || [[ "$avail" != "$want" ]]; then
  echo "FAIL: want replicas=$want ready=$ready available=$avail" >&2
  kubectl -n "$NS" get pods -l app="$DEPLOY" -o wide >&2
  exit 1
fi

echo "verify-deployments-lesson: OK ($NS/$DEPLOY replicas=$want ready=$ready)"
