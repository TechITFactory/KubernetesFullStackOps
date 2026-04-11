#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: setup-linux-lab-workspace.sh
# Lesson:  part-0-prerequisites / 0.1-linux-basics-for-kubernetes (README Step 2)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Sets LAB_ROOT to $K8SOPS_P0_LINUX_LAB, or default ~/k8sops-p0-linux-lab.
#   2. Fails if ../lab-files is missing (those files are the fake logs for grep practice).
#   3. mkdir -p LAB_ROOT, then cp -a copies everything from lab-files/ into LAB_ROOT
#      (overwrites/merges with same names — safe practice sandbox).
#   4. Prints the path so you know where to `cd` for the next steps.
#
# Exit: 0 success; 1 if lab-files directory missing.
# ------------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_SRC="${SCRIPT_DIR}/../lab-files"
LAB_ROOT="${K8SOPS_P0_LINUX_LAB:-${HOME}/k8sops-p0-linux-lab}"

if [[ ! -d "$LAB_SRC" ]]; then
  echo "Missing lab-files next to scripts/. Expected: $LAB_SRC" >&2
  exit 1
fi

mkdir -p "$LAB_ROOT"
cp -a "${LAB_SRC}/." "$LAB_ROOT/"
echo "Lab workspace ready at: $LAB_ROOT"
echo "Next: cd \"$LAB_ROOT\" and follow 0.1 README lab steps (or run ./verify-linux-basics.sh)."
