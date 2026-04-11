#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: collect-kubeadm-diagnostics.sh
# Lesson: 1.2.2.1.2-troubleshooting-kubeadm (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Creates OUTPUT_DIR (default ./kubeadm-diagnostics).
#   2. Runs many read-only commands (uname, systemctl status, journalctl, ip, ss, versions);
#      redirects stdout+stderr each to a .txt file. Non-zero exits become [WARN] but still capture output.
#   3. Prints path to the bundle — does not upload anywhere.
#
# Exit: 0 after all captures attempted.
# ------------------------------------------------------------------------------
set -euo pipefail

OUTPUT_DIR="${OUTPUT_DIR:-./kubeadm-diagnostics}"
mkdir -p "$OUTPUT_DIR"

run_capture() {
  local name="$1"
  shift
  if "$@" >"$OUTPUT_DIR/$name.txt" 2>&1; then
    echo "[OK] $name"
  else
    echo "[WARN] $name captured with non-zero exit"
  fi
}

run_capture uname uname -a
run_capture kubelet-status systemctl status kubelet --no-pager
run_capture kubelet-logs journalctl -u kubelet -n 300 --no-pager
run_capture container-runtime systemctl status containerd --no-pager
run_capture crio-status systemctl status crio --no-pager
run_capture cri-docker-status systemctl status cri-docker --no-pager
run_capture swap swapon --show
run_capture modules lsmod
run_capture ip-address ip addr
run_capture routes ip route
run_capture ports ss -tulpn
run_capture kubeadm-version kubeadm version
run_capture kubectl-version kubectl version --client

echo "Diagnostics written to $OUTPUT_DIR"
