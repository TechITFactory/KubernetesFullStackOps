#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-pod-lifecycle-lesson.sh
# Lesson: 2.4.1.1 Pod Lifecycle
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Checks kubectl and optional namespace (env NS, default: default).
#   2. Asserts Pod pod-lifecycle-demo exists and Ready=True.
#   3. Prints phase and restart count for the teaching recap.
#
# Prerequisite: you applied yamls/pod-lifecycle-demo.yaml (see lesson README).
# Exit: 0 if Ready; 1 otherwise.
# ------------------------------------------------------------------------------
set -euo pipefail

NS="${NS:-default}"
POD="pod-lifecycle-demo"

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

if ! kubectl -n "$NS" get pod "$POD" &>/dev/null; then
  echo "FAIL: Pod $NS/$POD not found. Run: kubectl apply -f yamls/pod-lifecycle-demo.yaml" >&2
  exit 1
fi

ready=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)
phase=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{.status.phase}' 2>/dev/null || true)
restarts=$(kubectl -n "$NS" get pod "$POD" -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || echo "?")

if [[ "$ready" != "True" ]]; then
  echo "FAIL: Pod $NS/$POD Ready=$ready phase=$phase (expected Ready=True, phase=Running)" >&2
  kubectl -n "$NS" describe pod "$POD" | tail -n 25 >&2 || true
  exit 1
fi

echo "verify-pod-lifecycle-lesson: OK ($NS/$POD phase=$phase restarts=$restarts Ready=True)"
