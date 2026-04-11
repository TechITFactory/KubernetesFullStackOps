#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: query-label-selectors.sh
# Lesson: 2.1.2.3-labels-and-selectors (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Lists pods cluster-wide with label app.kubernetes.io/name=demo-web.
#   2. Lists Services with label app.kubernetes.io/part-of=overview-module.
#
# Exit: 0; 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

kubectl get pods -A -l app.kubernetes.io/name=demo-web
kubectl get svc -A -l app.kubernetes.io/part-of=overview-module
