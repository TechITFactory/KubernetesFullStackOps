#!/usr/bin/env bash
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
