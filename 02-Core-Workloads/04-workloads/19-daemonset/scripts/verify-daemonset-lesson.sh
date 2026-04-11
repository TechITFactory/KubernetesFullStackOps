#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-daemonset-lesson.sh
# Lesson: 2.4.3.4 DaemonSet
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Waits for DaemonSet daemonset-demo rollout (NS default: default).
#   2. Asserts desiredNumberScheduled == currentNumberScheduled == numberReady
#      (normal on clusters where every node can run the pod).
#
# Prerequisite: kubectl apply -f yamls/daemonset-demo.yaml
# Exit: 0 on success. Fails if nodes are NotReady or taints block scheduling.
# ------------------------------------------------------------------------------
set -euo pipefail

NS="${NS:-default}"
DS="daemonset-demo"

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

if ! kubectl -n "$NS" get ds "$DS" &>/dev/null; then
  echo "FAIL: DaemonSet $NS/$DS not found. Run: kubectl apply -f yamls/daemonset-demo.yaml" >&2
  exit 1
fi

kubectl -n "$NS" rollout status "ds/$DS" --timeout=180s

des=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.status.desiredNumberScheduled}')
cur=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.status.currentNumberScheduled}')
rdy=$(kubectl -n "$NS" get ds "$DS" -o jsonpath='{.status.numberReady}')

des="${des:-0}"
cur="${cur:-0}"
rdy="${rdy:-0}"

if [[ "$des" != "$cur" ]] || [[ "$des" != "$rdy" ]]; then
  echo "FAIL: DaemonSet $NS/$DS desired=$des current=$cur ready=$rdy (expect all equal)" >&2
  echo "Hint: describe blocked pods — taints, node selectors, or NotReady nodes." >&2
  kubectl -n "$NS" get pods -l app="$DS" -o wide >&2
  exit 1
fi

if [[ "$des" -lt 1 ]]; then
  echo "FAIL: expected at least one schedulable node; desiredNumberScheduled=$des" >&2
  exit 1
fi

echo "verify-daemonset-lesson: OK ($NS/$DS pods on $des node(s))"
