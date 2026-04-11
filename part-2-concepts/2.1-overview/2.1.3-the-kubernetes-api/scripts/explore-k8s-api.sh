#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: explore-k8s-api.sh
# Lesson: part-2-concepts/2.1-overview/2.1.3-the-kubernetes-api (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. kubectl api-versions, api-resources, get --raw / — read-only API discovery.
#
# Exit: 0; 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

echo "[INFO] API groups:"
kubectl api-versions

echo
echo "[INFO] API resources:"
kubectl api-resources

echo
echo "[INFO] Root API discovery:"
kubectl get --raw /
