#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: check-cgroup-version.sh
# Lesson: 2.2.6-about-cgroup-v2 (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Checks /sys/fs/cgroup/cgroup.controllers — prints cgroup v2 vs v1/hybrid message.
#
# Exit: 0. Run on a Linux node (not from kubectl).
# ------------------------------------------------------------------------------
set -euo pipefail
if [[ -f /sys/fs/cgroup/cgroup.controllers ]]; then
  echo "cgroup v2 detected"
else
  echo "cgroup v1 or hybrid layout detected"
fi
