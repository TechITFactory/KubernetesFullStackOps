#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: garbage-collection-demo.sh
# Lesson: 2.2.8-garbage-collection (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. kubectl apply garbage-collection-demo.yaml; get deploy,rs,pods in gc-demo namespace.
#
# Exit: kubectl exit codes; 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail
command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }
kubectl apply -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../yamls/garbage-collection-demo.yaml"
kubectl get deploy,rs,pods -n gc-demo
