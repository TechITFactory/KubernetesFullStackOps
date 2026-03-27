#!/usr/bin/env bash
set -euo pipefail
command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }
kubectl get ingress -A
kubectl get pods -A | grep -i ingress || true
