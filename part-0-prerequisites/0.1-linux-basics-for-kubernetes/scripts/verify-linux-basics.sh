#!/usr/bin/env bash
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
