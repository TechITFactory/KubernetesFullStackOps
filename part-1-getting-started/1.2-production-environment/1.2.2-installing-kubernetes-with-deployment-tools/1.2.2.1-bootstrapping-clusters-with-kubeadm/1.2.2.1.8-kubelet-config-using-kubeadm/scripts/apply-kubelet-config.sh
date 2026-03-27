#!/usr/bin/env bash
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
