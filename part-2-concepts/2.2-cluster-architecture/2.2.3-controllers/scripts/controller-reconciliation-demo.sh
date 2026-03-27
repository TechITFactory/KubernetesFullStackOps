#!/usr/bin/env bash
set -euo pipefail
command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }
kubectl apply -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../yamls/controller-demo-deployment.yaml"
kubectl get deploy,pods -n controller-demo
echo "Delete one pod and watch reconciliation:"
echo "kubectl delete pod -n controller-demo -l app=controller-demo"
