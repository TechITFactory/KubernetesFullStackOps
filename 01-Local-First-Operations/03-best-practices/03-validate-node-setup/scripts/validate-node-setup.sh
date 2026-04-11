#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: validate-node-setup.sh
# Lesson: 03-validate-node-setup (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Read-only checks: kubelet/kubeadm/kubectl/sysctl/ss on PATH; swap must be off; overlay + br_netfilter
#      modules; sysctl bridge-nf-call-iptables and ip_forward == 1.
#   2. Reports presence of common CRI sockets (containerd, cri-o, cri-dockerd) — warns if missing.
#
# Exit: 0 if no blocking failures; 1 if required commands missing or swap enabled.
# ------------------------------------------------------------------------------
set -euo pipefail

failed=0

check_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[OK] command present: $cmd"
  else
    echo "[FAIL] command missing: $cmd"
    failed=1
  fi
}

check_file() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "[OK] path present: $path"
  else
    echo "[WARN] path missing: $path"
  fi
}

check_cmd kubelet
check_cmd kubeadm
check_cmd kubectl
check_cmd sysctl
check_cmd ss

if swapon --show | grep -q .; then
  echo "[FAIL] swap is enabled"
  failed=1
else
  echo "[OK] swap is disabled"
fi

for module in overlay br_netfilter; do
  if lsmod | awk '{print $1}' | grep -Fxq "$module"; then
    echo "[OK] kernel module loaded: $module"
  else
    echo "[WARN] kernel module not loaded: $module"
  fi
done

for key in net.bridge.bridge-nf-call-iptables net.ipv4.ip_forward; do
  value="$(sysctl -n "$key" 2>/dev/null || true)"
  if [[ "$value" == "1" ]]; then
    echo "[OK] sysctl $key=1"
  else
    echo "[WARN] sysctl $key is '$value'"
  fi
done

check_file /run/containerd/containerd.sock
check_file /var/run/crio/crio.sock
check_file /run/cri-dockerd.sock

if [[ "$failed" -ne 0 ]]; then
  echo "[FAIL] Node validation found blocking issues."
  exit 1
fi

echo "[OK] Node validation completed without blocking issues."
