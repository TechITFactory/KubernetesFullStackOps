#!/usr/bin/env bash
set -euo pipefail
for socket in /run/containerd/containerd.sock /var/run/crio/crio.sock /run/cri-dockerd.sock; do
  if [[ -S "$socket" ]]; then
    echo "Found CRI socket: $socket"
  fi
done
