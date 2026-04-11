#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: start-minikube.sh
# Lesson: 1.1.1-minikube-setup-and-configuration (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Requires minikube, kubectl; if DRIVER=docker (default), requires docker.
#   2. Checks minikube profile PROFILE (default kfsops-minikube): if already Running, skips start.
#      Otherwise runs minikube start with DRIVER, CPUS, MEMORY_MB, KUBERNETES_VERSION.
#   3. Enables ingress addon on that profile.
#   4. Verifies kubectl current-context, prints kubectl get nodes and smoke-test apply hint.
#
# Exit: 0 if cluster ready; non-zero if prerequisites or minikube start fail.
# ------------------------------------------------------------------------------
set -euo pipefail

DRIVER="${DRIVER:-docker}"
CPUS="${CPUS:-2}"
MEMORY_MB="${MEMORY_MB:-4096}"
KUBERNETES_VERSION="${KUBERNETES_VERSION:-stable}"
PROFILE="${PROFILE:-kfsops-minikube}"
CURRENT_STATUS=""

command -v minikube >/dev/null 2>&1 || {
  echo "minikube was not found in PATH. Run install-minikube.sh first." >&2
  exit 1
}

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl was not found in PATH." >&2
  exit 1
}

if [[ "$DRIVER" == "docker" ]]; then
  command -v docker >/dev/null 2>&1 || {
    echo "docker was not found in PATH, but DRIVER=docker was requested." >&2
    exit 1
  }
fi

if minikube profile list -o json >/tmp/minikube-profiles.json 2>/dev/null; then
  CURRENT_STATUS="$(sed -n "/\"Name\": \"$PROFILE\"/,/}/ s/.*\"Status\": \"\([^\"]*\)\".*/\1/p" /tmp/minikube-profiles.json | head -n 1)"
  rm -f /tmp/minikube-profiles.json
fi

if [[ "$CURRENT_STATUS" == "Running" ]]; then
  echo "Minikube profile '$PROFILE' is already running. Reusing it."
else
  minikube start \
    --driver="$DRIVER" \
    --cpus="$CPUS" \
    --memory="$MEMORY_MB" \
    --kubernetes-version="$KUBERNETES_VERSION" \
    --profile="$PROFILE"
fi

minikube addons enable ingress --profile "$PROFILE"
kubectl config current-context >/dev/null

echo "Cluster is ready."
kubectl get nodes
echo "Apply test workload with: kubectl apply -f ../yamls/smoke-test.yaml"
