#!/usr/bin/env bash
set -euo pipefail
if [[ -f /sys/fs/cgroup/cgroup.controllers ]]; then
  echo "cgroup v2 detected"
else
  echo "cgroup v1 or hybrid layout detected"
fi
