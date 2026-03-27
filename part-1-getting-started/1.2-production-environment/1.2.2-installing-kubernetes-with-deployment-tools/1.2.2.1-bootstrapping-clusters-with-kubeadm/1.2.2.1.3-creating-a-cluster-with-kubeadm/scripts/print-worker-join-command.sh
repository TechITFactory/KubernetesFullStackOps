#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run this script as root on a control-plane node." >&2
  exit 1
fi

kubeadm token create --print-join-command
