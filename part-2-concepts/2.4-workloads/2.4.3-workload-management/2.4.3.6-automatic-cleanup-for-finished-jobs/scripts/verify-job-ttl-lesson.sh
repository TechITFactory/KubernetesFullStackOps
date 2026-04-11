#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-job-ttl-lesson.sh
# Lesson: 2.4.3.6 Automatic cleanup for finished Jobs
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Waits for Job job-ttl-demo to complete.
#   2. Confirms spec.ttlSecondsAfterFinished is set (60 in the demo YAML).
#   3. Polls until the Job object is deleted (TTL controller; usually ~60s after finish).
#
# Prerequisite: kubectl apply -f yamls/job-ttl-demo.yaml
# Requires: TTLAfterFinished (on by default on supported clusters).
# Exit: 0 when Job is gone; 1 on timeout or missing TTL.
# ------------------------------------------------------------------------------
set -euo pipefail

NS="${NS:-default}"
JOB="job-ttl-demo"
TTL_EXPECT="${TTL_EXPECT:-60}"
POLL_SEC="${POLL_SEC:-5}"
MAX_WAIT_SEC="${MAX_WAIT_SEC:-180}"

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

if ! kubectl -n "$NS" get job "$JOB" &>/dev/null; then
  echo "FAIL: Job $NS/$JOB not found. Run: kubectl apply -f yamls/job-ttl-demo.yaml" >&2
  exit 1
fi

kubectl -n "$NS" wait --for=condition=complete "job/$JOB" --timeout=120s

ttl=$(kubectl -n "$NS" get job "$JOB" -o jsonpath='{.spec.ttlSecondsAfterFinished}' 2>/dev/null || true)
if [[ -z "$ttl" || "$ttl" != "$TTL_EXPECT" ]]; then
  echo "FAIL: expected spec.ttlSecondsAfterFinished=$TTL_EXPECT, got: ${ttl:-empty}" >&2
  exit 1
fi

echo "Job complete; TTL=$ttl — waiting for Job object deletion (TTL controller, up to ${MAX_WAIT_SEC}s)..."
elapsed=0
while kubectl -n "$NS" get job "$JOB" &>/dev/null; do
  if [[ "$elapsed" -ge "$MAX_WAIT_SEC" ]]; then
    echo "FAIL: Job still exists after ${MAX_WAIT_SEC}s — check TTL controller / feature gates" >&2
    kubectl -n "$NS" get job "$JOB" -o yaml | tail -n 20 >&2
    exit 1
  fi
  sleep "$POLL_SEC"
  elapsed=$((elapsed + POLL_SEC))
done

echo "verify-job-ttl-lesson: OK ($NS/$JOB removed after TTL)"
