#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: install-minikube.sh
# Lesson: 01.1-minikube-setup-and-configuration (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Requires curl + install (coreutils). Detects OS/arch (linux|darwin, amd64|arm64).
#   2. VERSION: first arg, or "latest" → resolves tag from GitHub API; skips download if
#      minikube already matches that version.
#   3. Downloads minikube binary from GCS, sudo install to INSTALL_DIR (default /usr/local/bin).
#   4. Unless SKIP_KUBECTL=true: fetches stable kubectl (or KUBECTL_VERSION), skips if version
#      matches, else downloads kubectl from dl.k8s.io and installs to INSTALL_DIR.
#   5. Prints next step hint (start-minikube.sh).
#
# Exit: 0 on success; 1 on unsupported OS/arch, network failure, or missing tools.
# ------------------------------------------------------------------------------
set -euo pipefail

VERSION="${1:-latest}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
KUBECTL_VERSION="${KUBECTL_VERSION:-stable}"
SKIP_KUBECTL="${SKIP_KUBECTL:-false}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Required command '$1' was not found in PATH." >&2
    exit 1
  }
}

normalize_version() {
  local version="$1"
  echo "${version#v}"
}

detect_os() {
  case "$(uname -s)" in
    Linux) echo "linux" ;;
    Darwin) echo "darwin" ;;
    *)
      echo "Unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo "amd64" ;;
    arm64|aarch64) echo "arm64" ;;
    *)
      echo "Unsupported architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac
}

install_kubectl() {
  local os="$1"
  local arch="$2"
  local version="$KUBECTL_VERSION"

  if [[ "$version" == "stable" ]]; then
    version="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
    if [[ -z "$version" ]]; then
      echo "Failed to fetch stable kubectl version." >&2
      exit 1
    fi
  fi

  if command -v kubectl >/dev/null 2>&1; then
    local current
    current="$(kubectl version --client --output=json 2>/dev/null | sed -n 's/.*"gitVersion":"\([^"]*\)".*/\1/p' | head -n 1)"
    if [[ -n "$current" ]] && [[ "$(normalize_version "$current")" == "$(normalize_version "$version")" ]]; then
      echo "kubectl ${current} is already installed. Skipping."
      return
    fi
  fi

  curl -fsSL -o kubectl "https://dl.k8s.io/release/${version}/bin/${os}/${arch}/kubectl"
  chmod +x kubectl
  sudo install kubectl "$INSTALL_DIR/kubectl"
  rm -f kubectl
}

require_cmd curl
require_cmd install

OS="$(detect_os)"
ARCH="$(detect_arch)"

if [[ "$VERSION" == "latest" ]]; then
  VERSION="$(curl -fsSL https://api.github.com/repos/kubernetes/minikube/releases/latest | sed -n 's/.*"tag_name": "\(.*\)".*/\1/p' | head -n 1)"
  if [[ -z "$VERSION" ]]; then
    echo "Failed to fetch latest minikube version (possible GitHub API rate limit). Pass a version explicitly, e.g.: $0 v038.1" >&2
    exit 1
  fi
fi

if command -v minikube >/dev/null 2>&1; then
  CURRENT_MINIKUBE="$(minikube version --short 2>/dev/null | awk '{print $NF}' | head -n 1)"
else
  CURRENT_MINIKUBE=""
fi

if [[ -n "$CURRENT_MINIKUBE" ]] && [[ "$(normalize_version "$CURRENT_MINIKUBE")" == "$(normalize_version "$VERSION")" ]]; then
  echo "Minikube ${CURRENT_MINIKUBE} is already installed. Skipping."
else
  curl -fsSL -o minikube "https://storage.googleapis.com/minikube/releases/${VERSION}/minikube-${OS}-${ARCH}"
  sudo install minikube "$INSTALL_DIR/minikube"
  rm -f minikube
  echo "Minikube installation completed."
fi

if [[ "$SKIP_KUBECTL" != "true" ]]; then
  install_kubectl "$OS" "$ARCH"
fi

if [[ "$SKIP_KUBECTL" != "true" ]]; then
  echo "kubectl is ready."
fi
echo "Next step: ./start-minikube.sh"
