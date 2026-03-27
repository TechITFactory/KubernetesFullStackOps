#!/usr/bin/env bash
set -euo pipefail
command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }
kubectl apply -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../yamls/garbage-collection-demo.yaml"
kubectl get deploy,rs,pods -n gc-demo
