#!/usr/bin/env bash
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

kubectl get pods -A -l app.kubernetes.io/name=demo-web
kubectl get svc -A -l app.kubernetes.io/part-of=overview-module
