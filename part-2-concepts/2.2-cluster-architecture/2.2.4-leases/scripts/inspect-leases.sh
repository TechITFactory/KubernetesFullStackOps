#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: inspect-leases.sh
# Lesson: 2.2.4-leases (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. kubectl get leases -A (all namespaces) — read-only.
#
# Exit: 0; 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail
command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }
kubectl get leases -A
