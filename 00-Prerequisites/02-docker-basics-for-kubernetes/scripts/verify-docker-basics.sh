#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-docker-basics.sh
# Lesson:  00-Prerequisites / 02-docker-basics-for-kubernetes (README Step 6)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Verifies `docker` is on PATH; verifies daemon is reachable via `docker info`.
#   2. docker pull hello-world — downloads the tiny test image from Docker Hub.
#   3. docker run --rm hello-world — creates a throwaway container, runs it, removes it.
#   4. docker build -t $IMAGE_TAG ../docker — builds the course Dockerfile (default tag
#      k8sops-p0-lab:0.2; override with env K8SOPS_P0_DOCKER_IMAGE).
#   5. docker run --rm $IMAGE_TAG — runs that image once to prove it works.
#   6. Prints verify-docker-basics: OK.
#
# Exit: 0 on success; non-zero if any docker command fails.
# ------------------------------------------------------------------------------
set -euo pipefail

command -v docker >/dev/null 2>&1 || {
  echo "docker not found in PATH. Install Docker Engine or Docker Desktop, then retry." >&2
  exit 1
}

docker info >/dev/null 2>&1 || {
  echo "Docker CLI is present but the daemon is not reachable. Start Docker Desktop / docker.service." >&2
  exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_TAG="${K8SOPS_P0_DOCKER_IMAGE:-k8sops-p0-lab:0.2}"

echo "== Pull hello-world (registry pull path) =="
docker pull hello-world

echo "== Run hello-world (create + remove container) =="
docker run --rm hello-world

echo "== Build custom image from docker/Dockerfile =="
docker build -t "$IMAGE_TAG" "${SCRIPT_DIR}/../docker"

echo "== Run custom image =="
docker run --rm "$IMAGE_TAG"

echo "verify-docker-basics: OK (image $IMAGE_TAG built and ran)"
