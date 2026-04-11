#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-jobs-lesson.sh
# Lesson: 2.4.3.5 Jobs
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Waits for Job job-demo to reach Complete=True (NS default: default).
#   2. Greps pod logs for the expected echo line (best-effort if pod already gone).
#
# Prerequisite: kubectl apply -f yamls/job-demo.yaml
# Exit: 0 on success.
# ------------------------------------------------------------------------------
set -euo pipefail

NS="${NS:-default}"
JOB="job-demo"

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

if ! kubectl -n "$NS" get job "$JOB" &>/dev/null; then
  echo "FAIL: Job $NS/$JOB not found. Run: kubectl apply -f yamls/job-demo.yaml" >&2
  exit 1
fi

kubectl -n "$NS" wait --for=condition=complete "job/$JOB" --timeout=120s

ctype=$(kubectl -n "$NS" get job "$JOB" -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}' 2>/dev/null || true)
if [[ "$ctype" != "True" ]]; then
  echo "FAIL: Job Complete condition not True (got: $ctype)" >&2
  kubectl -n "$NS" describe job "$JOB" >&2
  exit 1
fi

if log_out=$(kubectl -n "$NS" logs "job/$JOB" 2>/dev/null); then
  if echo "$log_out" | grep -q 'hello from job'; then
    echo "verify-jobs-lesson: OK ($NS/$JOB complete; log line matched)"
  else
    echo "FAIL: logs did not contain 'hello from job'" >&2
    echo "$log_out" >&2
    exit 1
  fi
else
  echo "verify-jobs-lesson: OK ($NS/$JOB complete; logs unavailable (TTL/cleanup) — job condition Complete=True only)"
fi
