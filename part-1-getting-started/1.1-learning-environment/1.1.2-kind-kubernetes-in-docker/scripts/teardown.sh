#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-kfsops-kind}"

command -v kind >/dev/null 2>&1 || {
  echo "kind was not found in PATH." >&2
  exit 1
}

if kind get clusters 2>/dev/null | grep -Fxq "$CLUSTER_NAME"; then
  echo "==> Deleting Kind cluster '$CLUSTER_NAME'..."
  kind delete cluster --name "$CLUSTER_NAME"
  echo "Teardown complete."
else
  echo "Kind cluster '$CLUSTER_NAME' does not exist. Nothing to tear down."
fi
