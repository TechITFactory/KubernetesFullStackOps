#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: self-healing-demo.sh
# Lesson: 2.2.7-kubernetes-self-healing (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. kubectl apply self-healing-demo.yaml; get deploy,pods in namespace self-healing-demo.
#
# Exit: kubectl exit codes; 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail
command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }
kubectl apply -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../yamls/self-healing-demo.yaml"
kubectl get deploy,pods -n self-healing-demo
