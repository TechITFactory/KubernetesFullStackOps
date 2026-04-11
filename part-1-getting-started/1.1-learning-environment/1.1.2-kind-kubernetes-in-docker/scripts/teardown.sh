#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: teardown.sh (Kind)
# Lesson: 1.1.2-kind-kubernetes-in-docker (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Requires kind. If CLUSTER_NAME (default kfsops-kind) exists → kind delete cluster.
#      Else prints nothing to delete.
#
# Exit: 0; non-zero if kind missing or delete fails.
# ------------------------------------------------------------------------------
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
