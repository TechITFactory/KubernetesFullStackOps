#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: teardown.sh (Minikube)
# Lesson: 01.1-minikube-setup-and-configuration (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Requires minikube on PATH.
#   2. If profile PROFILE (default kfsops-minikube) exists: minikube delete --profile (stops VM,
#      removes profile). Else prints nothing-to-do message.
#
# Exit: 0 (including "already gone"); non-zero if minikube missing or delete fails.
# ------------------------------------------------------------------------------
set -euo pipefail

PROFILE="${PROFILE:-kfsops-minikube}"

command -v minikube >/dev/null 2>&1 || {
  echo "minikube was not found in PATH." >&2
  exit 1
}

if minikube profile list -o json 2>/dev/null | grep -q "\"Name\": \"$PROFILE\""; then
  echo "==> Stopping and deleting Minikube profile '$PROFILE'..."
  minikube delete --profile "$PROFILE"
  echo "Teardown complete."
else
  echo "Minikube profile '$PROFILE' does not exist. Nothing to tear down."
fi
