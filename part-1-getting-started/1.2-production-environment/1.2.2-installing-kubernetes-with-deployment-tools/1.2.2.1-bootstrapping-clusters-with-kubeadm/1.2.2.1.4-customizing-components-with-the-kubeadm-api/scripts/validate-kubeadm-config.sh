#!/usr/bin/env bash
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
