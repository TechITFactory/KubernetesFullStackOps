#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: inspect-2-5-1-service.sh
# Lesson: 2.5.1 Service
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Lists Services in all namespaces (read-only).
#   2. Lists EndpointSlices cluster-wide when the API is available (read-only).
#
# Use after applying service-clusterip-demo.yaml to also run:
#   kubectl -n svc-demo get svc,endpoints,pods
#
# Exit: 0
# ------------------------------------------------------------------------------
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

echo "==> Services (all namespaces)"
kubectl get svc -A

echo ""
echo "==> EndpointSlices (all namespaces, if available)"
if kubectl get endpointslices -A &>/dev/null; then
  kubectl get endpointslices -A | head -n 40
else
  echo "(EndpointSlices API not available or access denied)"
fi
