#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: print-worker-join-command.sh
# Lesson: 1.2.2.1.3-creating-a-cluster-with-kubeadm (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Must run as root on a control-plane node.
#   2. kubeadm token create --print-join-command — prints a one-line command to run on worker nodes.
#
# Exit: kubeadm exit code (0 if token created and command printed).
# ------------------------------------------------------------------------------
set -euo pipefail

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "Run this script as root on a control-plane node." >&2
  exit 1
fi

kubeadm token create --print-join-command
