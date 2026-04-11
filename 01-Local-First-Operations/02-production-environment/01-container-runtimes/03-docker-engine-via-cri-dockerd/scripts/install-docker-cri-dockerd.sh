#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: install-docker-cri-dockerd.sh
# Lesson: 003-docker-engine-via-cri-dockerd (Debian/Ubuntu-style; see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Must run as root. apt-get update; installs docker.io and cri-dockerd if missing.
#   2. Enables and starts docker + cri-docker.socket; restarts both services.
#
# Exit: 0 on success; non-zero on apt or systemd failure.
# ------------------------------------------------------------------------------
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
