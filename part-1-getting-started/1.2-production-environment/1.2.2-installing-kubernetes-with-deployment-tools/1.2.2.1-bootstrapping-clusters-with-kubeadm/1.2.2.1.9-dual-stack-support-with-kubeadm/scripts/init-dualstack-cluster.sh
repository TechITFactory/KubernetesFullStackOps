#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: init-dualstack-cluster.sh
# Lesson: 1.2.2.1.9-dual-stack-support-with-kubeadm (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Must run as root. CONFIG_PATH defaults to ../yamls/kubeadm-dualstack-config.yaml.
#   2. If /etc/kubernetes/admin.conf exists → skip. Else kubeadm init --config (dual-stack settings in YAML).
#
# Exit: 0 or kubeadm’s exit code.
# ------------------------------------------------------------------------------
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
