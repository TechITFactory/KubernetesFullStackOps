#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: controller-reconciliation-demo.sh
# Lesson: 2.2.3-controllers (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. kubectl apply controller-demo-deployment.yaml (Namespace + Deployment in controller-demo).
#   2. kubectl get deploy,pods -n controller-demo; prints hint to delete a pod to see reconcile.
#
# Exit: kubectl exit codes; 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail
command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }
kubectl apply -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../yamls/controller-demo-deployment.yaml"
kubectl get deploy,pods -n controller-demo
echo "Delete one pod and watch reconciliation:"
echo "kubectl delete pod -n controller-demo -l app=controller-demo"
