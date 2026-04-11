#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: show-owner-references.sh
# Lesson: 2.1.2.8-owners-and-dependents (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Prints ReplicaSets and Pods in owner-demo with jsonpath owner chain (read-only).
#
# Exit: 0; 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

kubectl get rs,pods -n owner-demo -o jsonpath='{range .items[*]}{.kind}{" "}{.metadata.name}{" -> "}{range .metadata.ownerReferences[*]}{.kind}{"/"}{.name}{" "}{end}{"\n"}{end}'
