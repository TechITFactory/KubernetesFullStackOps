#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: inspect-cri-endpoint.sh
# Lesson: part-2-concepts/2.3-containers/2.3.5-container-runtime-interface-cri (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Scans common CRI Unix sockets: containerd, CRI-O, cri-dockerd.
#   2. Prints "Found CRI socket" for each that exists (-S test).
#   3. If crictl is on PATH and at least one socket exists, runs
#        crictl --runtime-endpoint unix://<first-found> info
#      and prints the first 20 lines (may fail without sudo — see message).
#   4. If no socket found, prints a warning (typical when run from a dev laptop).
#
# Exit: 0 (informational); non-zero only from set -e if a command fails unexpectedly.
# ------------------------------------------------------------------------------
set -euo pipefail

first_socket=""
for socket in /run/containerd/containerd.sock /var/run/crio/crio.sock /run/cri-dockerd.sock; do
  if [[ -S "$socket" ]]; then
    echo "Found CRI socket: $socket"
    [[ -z "$first_socket" ]] && first_socket="$socket"
  fi
done

if [[ -z "$first_socket" ]]; then
  echo "[WARN] No common CRI socket found. Run this script on a Linux Kubernetes node (SSH), not only from kubectl on your laptop."
  exit 0
fi

if command -v crictl >/dev/null 2>&1; then
  echo "[INFO] crictl info (first socket, first 20 lines):"
  set +e
  crictl --runtime-endpoint "unix://${first_socket}" info 2>/dev/null | head -n 20
  rc="${PIPESTATUS[0]}"
  set -e
  if [[ "$rc" -ne 0 ]]; then
    echo "[WARN] crictl info failed — try: sudo crictl --runtime-endpoint unix://${first_socket} info"
  fi
else
  echo "[INFO] crictl not in PATH; socket discovery only. Install crictl for full CRI checks."
fi
