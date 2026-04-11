#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: inspect-cloud-controller-manager.sh
# Lesson: 2.2.5-cloud-controller-manager (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Tries to list kube-system pods for cloud-controller-manager; greps kube-system for cloud — read-only.
#
# Exit: 0 (|| true paths); 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail
command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }
kubectl get pods -n kube-system -l component=cloud-controller-manager || true
kubectl get pods -n kube-system | grep -i cloud || true
