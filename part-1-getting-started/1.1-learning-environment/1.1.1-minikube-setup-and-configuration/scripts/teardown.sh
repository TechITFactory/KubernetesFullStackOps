#!/usr/bin/env bash
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
