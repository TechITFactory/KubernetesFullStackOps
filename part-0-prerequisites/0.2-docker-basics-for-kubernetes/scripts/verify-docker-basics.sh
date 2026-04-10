#!/usr/bin/env bash
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
