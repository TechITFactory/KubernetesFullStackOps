#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: check-local-prereqs.sh
# Lesson: 1.1.3-local-development-clusters (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Prints [OK]/[MISSING]/[OPTIONAL] for: kubectl (required), docker, minikube, kind, helm.
#   2. Prints current kubectl context (or note if none) — read-only; does not change cluster.
#
# Exit: always 0 from script logic (even if tools missing); individual lines tell the story.
# ------------------------------------------------------------------------------
set -euo pipefail

check() {
  local name="$1"
  local required="$2"

  if command -v "$name" >/dev/null 2>&1; then
    echo "[OK] $name"
  elif [[ "$required" == "required" ]]; then
    echo "[MISSING] $name"
  else
    echo "[OPTIONAL] $name not found"
  fi
}

check kubectl required
check docker optional
check minikube optional
check kind optional
check helm optional

echo
echo "Current kubectl context:"
if command -v kubectl >/dev/null 2>&1; then
  kubectl config current-context 2>/dev/null || echo "[INFO] No current kubectl context is set yet"
fi
