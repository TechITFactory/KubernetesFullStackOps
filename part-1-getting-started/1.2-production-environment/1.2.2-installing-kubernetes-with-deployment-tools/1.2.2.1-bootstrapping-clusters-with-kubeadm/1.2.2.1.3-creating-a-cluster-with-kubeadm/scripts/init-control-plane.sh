#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: init-control-plane.sh
# Lesson: 1.2.2.1.3-creating-a-cluster-with-kubeadm (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Must run as root. CONFIG_PATH defaults to ../yamls/kubeadm-init-config.yaml.
#   2. If /etc/kubernetes/admin.conf missing → kubeadm init --config. Else skips (already initialized).
#   3. Copies admin kubeconfig to $HOME/.kube/config with correct ownership.
#   4. kubectl get nodes (as your user, using the copied config).
#
# Exit: 0 on success; non-zero if init or kubectl fails.
# ------------------------------------------------------------------------------
set -euo pipefail

CONFIG_PATH="${CONFIG_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../yamls/kubeadm-init-config.yaml}"

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run this script as root." >&2
  exit 1
fi

if [[ -f /etc/kubernetes/admin.conf ]]; then
  echo "A kubeadm control plane already appears initialized. Skipping kubeadm init."
else
  kubeadm init --config "$CONFIG_PATH"
fi

mkdir -p "$HOME/.kube"
cp -f /etc/kubernetes/admin.conf "$HOME/.kube/config"
chown "$(id -u):$(id -g)" "$HOME/.kube/config"

kubectl get nodes
echo "Control plane is ready."
