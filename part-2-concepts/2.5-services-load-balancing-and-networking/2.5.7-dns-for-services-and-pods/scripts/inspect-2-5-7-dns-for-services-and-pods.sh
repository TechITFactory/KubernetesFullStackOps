#!/usr/bin/env bash
set -euo pipefail
command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }
kubectl get svc -A
echo
kubectl get endpointslices -A 2>/dev/null || kubectl get endpointslices -A
