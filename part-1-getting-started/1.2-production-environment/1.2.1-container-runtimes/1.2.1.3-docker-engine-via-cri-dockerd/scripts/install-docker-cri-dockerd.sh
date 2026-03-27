#!/usr/bin/env bash
set -euo pipefail

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

for pkg in docker.io cri-dockerd; do
  if ! package_installed "$pkg"; then
    apt-get install -y "$pkg"
  else
    echo "$pkg already installed. Skipping."
  fi
done

systemctl enable --now docker
systemctl enable --now cri-docker.socket
systemctl restart docker
systemctl restart cri-docker

echo "Docker Engine with cri-dockerd is ready."
echo "CRI socket: /run/cri-dockerd.sock"
