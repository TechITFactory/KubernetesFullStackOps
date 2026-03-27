#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH="${CONFIG_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../yamls/kubeadm-dualstack-config.yaml}"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

if [[ -f /etc/kubernetes/admin.conf ]]; then
  echo "A cluster already appears initialized on this node. Skipping dual-stack init."
else
  kubeadm init --config "$CONFIG_PATH"
fi

echo "Dual-stack kubeadm init completed."
