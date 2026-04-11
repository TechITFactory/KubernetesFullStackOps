#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: init-ha-control-plane.sh
# Lesson: 02.1.6-creating-highly-available-clusters-with-kubeadm (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Must run as root. CONFIG_PATH defaults to ../yamls/ha-kubeadm-config.yaml.
#   2. If admin.conf exists → skip. Else kubeadm init --config ... --upload-certs (for additional CP nodes).
#
# Exit: kubeadm / script success; non-zero on init failure.
# ------------------------------------------------------------------------------
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
