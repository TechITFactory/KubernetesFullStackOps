#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: validate-kubeadm-config.sh
# Lesson: 1.2.2.1.4-customizing-components-with-the-kubeadm-api (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Requires kubeadm. CONFIG_PATH defaults to ../yamls/custom-cluster-config.yaml.
#   2. kubeadm config validate --config (syntax/field checks).
#   3. kubeadm config print init-defaults for comparison; prints hint to use init --config.
#
# Exit: 0 if validate passes; non-zero if kubeadm validate fails.
# ------------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="${CONFIG_PATH:-$SCRIPT_DIR/../yamls/custom-cluster-config.yaml}"

command -v kubeadm >/dev/null 2>&1 || {
  echo "kubeadm was not found in PATH. Run install-kubeadm.sh first." >&2
  exit 1
}

echo "==> Validating kubeadm config: $CONFIG_PATH"
kubeadm config validate --config "$CONFIG_PATH"

echo ""
echo "==> Printing effective default config for comparison:"
kubeadm config print init-defaults

echo ""
echo "Config is valid. Use it with: kubeadm init --config $CONFIG_PATH"
