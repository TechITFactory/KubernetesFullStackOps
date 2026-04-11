#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: install-kubeadm.sh
# Lesson: 1.2.2.1.1-installing-kubeadm (Debian/Ubuntu + pkgs.k8s.io; see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Must run as root. Installs apt HTTPS tooling; adds Kubernetes apt repo for K8S_MINOR_VERSION
#      (default v1.35) with signed-by keyring.
#   2. apt-get install kubelet kubeadm kubectl (skip if already installed); apt-mark hold on those packages.
#   3. systemctl enable --now kubelet (|| true so script continues if kubelet not fully configured yet).
#
# Exit: 0 on success; non-zero on curl/apt failure.
# ------------------------------------------------------------------------------
set -euo pipefail

K8S_MINOR_VERSION="${K8S_MINOR_VERSION:-v1.35}"

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
apt-get install -y apt-transport-https ca-certificates curl gpg

install -d -m 0755 /etc/apt/keyrings

if [[ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]]; then
  curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_MINOR_VERSION}/deb/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
fi

REPO_LINE="deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_MINOR_VERSION}/deb/ /"
REPO_FILE="/etc/apt/sources.list.d/kubernetes.list"

if [[ ! -f "$REPO_FILE" ]] || ! grep -Fqx "$REPO_LINE" "$REPO_FILE"; then
  echo "$REPO_LINE" > "$REPO_FILE"
fi

apt-get update
for pkg in kubelet kubeadm kubectl; do
  if ! package_installed "$pkg"; then
    apt-get install -y "$pkg"
  else
    echo "$pkg already installed. Skipping package install."
  fi
done

apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet || true

echo "kubeadm tooling is ready."
