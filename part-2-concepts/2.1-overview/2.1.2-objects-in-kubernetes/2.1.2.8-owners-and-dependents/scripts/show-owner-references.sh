#!/usr/bin/env bash
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

kubectl get rs,pods -n owner-demo -o jsonpath='{range .items[*]}{.kind}{" "}{.metadata.name}{" -> "}{range .metadata.ownerReferences[*]}{.kind}{"/"}{.name}{" "}{end}{"\n"}{end}'
