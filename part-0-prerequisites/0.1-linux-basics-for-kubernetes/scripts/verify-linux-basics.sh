#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-linux-basics.sh
# Lesson:  part-0-prerequisites / 0.1-linux-basics-for-kubernetes (README Step 8)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Expects LAB_ROOT (default ~/k8sops-p0-linux-lab) to already exist with files
#      from setup-linux-lab-workspace.sh — exits 1 if servers.log is missing.
#   2. cd into LAB_ROOT.
#   3. Counts lines matching ' ERROR ' in servers.log (must be >= 1).
#   4. Counts total lines in servers.log (must be >= 3).
#   5. Checks nested/data.txt exists.
#   6. Prints OK with counts, or FAIL + exit 1 if any check fails.
#
# Exit: 0 if all checks pass; 1 otherwise.
# ------------------------------------------------------------------------------
set -euo pipefail

LAB_ROOT="${K8SOPS_P0_LINUX_LAB:-${HOME}/k8sops-p0-linux-lab}"

if [[ ! -f "${LAB_ROOT}/servers.log" ]]; then
  echo "Run setup-linux-lab-workspace.sh first (workspace missing: $LAB_ROOT)" >&2
  exit 1
fi

cd "$LAB_ROOT"

errors="$(grep -c ' ERROR ' servers.log || true)"
lines="$(wc -l < servers.log | tr -d ' ')"
nested="$(test -f nested/data.txt && echo ok || echo missing)"

if [[ "$errors" -lt 1 ]]; then
  echo "FAIL: expected at least one ERROR line in servers.log" >&2
  exit 1
fi

if [[ "$lines" -lt 3 ]]; then
  echo "FAIL: servers.log seems too short" >&2
  exit 1
fi

if [[ "$nested" != "ok" ]]; then
  echo "FAIL: nested/data.txt missing" >&2
  exit 1
fi

echo "verify-linux-basics: OK (ERROR lines=$errors, log lines=$lines, nested=$nested)"
