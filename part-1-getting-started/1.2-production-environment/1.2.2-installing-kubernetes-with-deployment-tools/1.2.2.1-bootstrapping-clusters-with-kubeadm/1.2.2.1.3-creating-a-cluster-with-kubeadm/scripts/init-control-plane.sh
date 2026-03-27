#!/usr/bin/env bash
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
