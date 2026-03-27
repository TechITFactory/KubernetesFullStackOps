#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH="${CONFIG_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../yamls/ha-kubeadm-config.yaml}"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

if [[ -f /etc/kubernetes/admin.conf ]]; then
  echo "This node already appears initialized as a control plane. Skipping."
else
  kubeadm init --config "$CONFIG_PATH" --upload-certs
fi

echo "HA control-plane bootstrap completed."
