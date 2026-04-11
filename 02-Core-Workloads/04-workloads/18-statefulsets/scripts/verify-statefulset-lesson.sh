#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-statefulset-lesson.sh
# Lesson: 2.4.3.3 StatefulSets
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Waits for StatefulSet statefulset-demo to roll out (NS default: default).
#   2. Checks spec.replicas match status.readyReplicas and pod names use ordinals -0, -1, ...
#
# Prerequisite: kubectl apply -f yamls/statefulset-demo.yaml (Service + StatefulSet)
# Exit: 0 on success.
# ------------------------------------------------------------------------------
set -euo pipefail

NS="${NS:-default}"
STS="statefulset-demo"

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

if ! kubectl -n "$NS" get sts "$STS" &>/dev/null; then
  echo "FAIL: StatefulSet $NS/$STS not found. Run: kubectl apply -f yamls/statefulset-demo.yaml" >&2
  exit 1
fi

kubectl -n "$NS" rollout status "sts/$STS" --timeout=180s

want=$(kubectl -n "$NS" get sts "$STS" -o jsonpath='{.spec.replicas}')
ready=$(kubectl -n "$NS" get sts "$STS" -o jsonpath='{.status.readyReplicas}')
curr=$(kubectl -n "$NS" get sts "$STS" -o jsonpath='{.status.currentReplicas}')

ready="${ready:-0}"
curr="${curr:-0}"

if [[ "$ready" != "$want" ]] || [[ "$curr" != "$want" ]]; then
  echo "FAIL: want replicas=$want currentReplicas=$curr readyReplicas=$ready" >&2
  kubectl -n "$NS" get pods -l app="$STS" -o wide >&2
  exit 1
fi

pods=$(kubectl -n "$NS" get pods -l "app=$STS" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || true)
expected=()
for ((i=0; i<want; i++)); do
  expected+=("${STS}-${i}")
done
for name in "${expected[@]}"; do
  if [[ ! " $pods " =~ " $name " ]]; then
    echo "FAIL: expected pod $name in list: $pods" >&2
    exit 1
  fi
done

cip=$(kubectl -n "$NS" get svc "$STS" -o jsonpath='{.spec.clusterIP}' 2>/dev/null || true)
if [[ -n "$cip" && "$cip" != "None" ]]; then
  echo "WARN: Service $STS should be headless (clusterIP None); got: $cip" >&2
fi

echo "verify-statefulset-lesson: OK ($NS/$STS replicas=$want pods: ${expected[*]})"
