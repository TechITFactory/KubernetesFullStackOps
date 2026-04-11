#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: apply-pod-security-labels.sh
# Lesson: 1.3.4-enforcing-pod-security-standards (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Requires kubectl. Ensures namespace NAMESPACE exists (default pss-restricted) via dry-run apply.
#   2. kubectl label namespace with pod-security.kubernetes.io enforce/warn/audit (+ version=latest),
#      levels default to restricted (overridable by env vars).
#
# Exit: 0 on success; non-zero if kubectl fails.
# ------------------------------------------------------------------------------
set -euo pipefail

NAMESPACE="${NAMESPACE:-pss-restricted}"
ENFORCE_LEVEL="${ENFORCE_LEVEL:-restricted}"
WARN_LEVEL="${WARN_LEVEL:-restricted}"
AUDIT_LEVEL="${AUDIT_LEVEL:-restricted}"

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace "$NAMESPACE" \
  pod-security.kubernetes.io/enforce="$ENFORCE_LEVEL" \
  pod-security.kubernetes.io/enforce-version=latest \
  pod-security.kubernetes.io/warn="$WARN_LEVEL" \
  pod-security.kubernetes.io/warn-version=latest \
  pod-security.kubernetes.io/audit="$AUDIT_LEVEL" \
  pod-security.kubernetes.io/audit-version=latest \
  --overwrite

echo "[INFO] Pod Security labels applied to namespace '$NAMESPACE'."
