#!/usr/bin/env bash
set -euo pipefail

CONTAINERD_CONFIG="${CONTAINERD_CONFIG:-/etc/containerd/config.toml}"

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
  fi
}

package_installed() {
  dpkg -s "$1" >/dev/null 2>&1
}

require_root

export DEBIAN_FRONTEND=noninteractive

apt-get update

if ! package_installed containerd; then
  apt-get install -y containerd
else
  echo "containerd package already installed. Skipping package install."
fi

mkdir -p /etc/containerd

if [[ ! -f "$CONTAINERD_CONFIG" ]]; then
  containerd config default > "$CONTAINERD_CONFIG"
fi

python3 - <<'PY'
from pathlib import Path
path = Path("/etc/containerd/config.toml")
text = path.read_text()
original = text
if 'disabled_plugins = ["cri"]' in text:
    text = text.replace('disabled_plugins = ["cri"]', 'disabled_plugins = []')
if 'SystemdCgroup = false' in text:
    text = text.replace('SystemdCgroup = false', 'SystemdCgroup = true')
if text != original:
    path.write_text(text)
PY

systemctl enable --now containerd
systemctl restart containerd

echo "containerd is ready."
echo "CRI socket: /run/containerd/containerd.sock"
