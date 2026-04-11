#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-cronjob-lesson.sh
# Lesson: 2.4.3.7 CronJob
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Confirms CronJob cronjob-demo exists.
#   2. Creates a one-off Job from that CronJob (same pod template) via
#      kubectl create job ... --from=cronjob/...
#   3. Waits for Complete, checks logs contain output from `date`, deletes the verify Job.
#
# Prerequisite: kubectl apply -f yamls/cronjob-demo.yaml
# Exit: 0 on success.
# ------------------------------------------------------------------------------
set -euo pipefail

NS="${NS:-default}"
CJ="cronjob-demo"
VERIFY_JOB="cj-verify-$(date +%s)"

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

if ! kubectl -n "$NS" get cronjob "$CJ" &>/dev/null; then
  echo "FAIL: CronJob $NS/$CJ not found. Run: kubectl apply -f yamls/cronjob-demo.yaml" >&2
  exit 1
fi

kubectl -n "$NS" create job "$VERIFY_JOB" --from="cronjob/$CJ"

cleanup() { kubectl -n "$NS" delete job "$VERIFY_JOB" --ignore-not-found &>/dev/null || true; }
trap cleanup EXIT

kubectl -n "$NS" wait --for=condition=complete "job/$VERIFY_JOB" --timeout=120s

if ! log_out=$(kubectl -n "$NS" logs "job/$VERIFY_JOB" 2>/dev/null); then
  echo "FAIL: could not read logs for job/$VERIFY_JOB" >&2
  exit 1
fi

# `date` output varies by locale; require a year-like digit sequence or weekday
if ! echo "$log_out" | grep -qE '[0-9]{4}|[A-Za-z]{3}.*[0-9]'; then
  echo "FAIL: logs do not look like date output" >&2
  echo "$log_out" >&2
  exit 1
fi

echo "verify-cronjob-lesson: OK ($NS/$CJ template ran via job/$VERIFY_JOB)"
