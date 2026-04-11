#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: inspect-nodes.sh
# Lesson: 2.2.1-nodes (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. kubectl get nodes -o wide; describe all nodes (first ~120 lines of combined describe).
#
# Exit: 0; 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail
command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }
kubectl get nodes -o wide
echo
kubectl describe nodes | sed -n '1,120p'
