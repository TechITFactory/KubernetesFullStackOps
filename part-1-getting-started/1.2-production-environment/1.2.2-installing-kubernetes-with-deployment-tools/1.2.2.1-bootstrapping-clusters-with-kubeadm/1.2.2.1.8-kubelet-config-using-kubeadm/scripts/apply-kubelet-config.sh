#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: apply-kubelet-config.sh
# Lesson: 1.2.2.1.8-kubelet-config-using-kubeadm (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Must run as root. Copies SOURCE_CONFIG (default ../yamls/kubeletconfiguration.yaml) to
#      TARGET_CONFIG (default /var/lib/kubelet/config.yaml) with install -D -m 0644.
#   2. systemctl restart kubelet.
#
# Exit: 0 on success; non-zero if copy or restart fails.
# ------------------------------------------------------------------------------
set -euo pipefail

SOURCE_CONFIG="${SOURCE_CONFIG:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../yamls/kubeletconfiguration.yaml}"
TARGET_CONFIG="${TARGET_CONFIG:-/var/lib/kubelet/config.yaml}"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

install -D -m 0644 "$SOURCE_CONFIG" "$TARGET_CONFIG"
systemctl restart kubelet

echo "Kubelet config applied to $TARGET_CONFIG"
