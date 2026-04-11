#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: inspect-node-control-plane-communication.sh
# Lesson: 2.2.2-communication-between-nodes-and-the-control-plane (README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. kubectl get nodes; kubectl get leases -n kube-node-lease (heartbeat leases).
#
# Exit: 0; 1 if kubectl missing.
# ------------------------------------------------------------------------------
set -euo pipefail
command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }
kubectl get nodes
echo
kubectl get leases -n kube-node-lease
