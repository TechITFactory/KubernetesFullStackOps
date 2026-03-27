#!/usr/bin/env bash
set -euo pipefail
command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }
kubectl get nodes -o wide
echo
kubectl describe nodes | sed -n '1,120p'
