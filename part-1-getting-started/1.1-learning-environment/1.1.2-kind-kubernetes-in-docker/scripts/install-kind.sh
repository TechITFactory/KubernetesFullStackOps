#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-v0.23.0}"
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

if command -v kind >/dev/null 2>&1; then
  CURRENT_KIND="$(kind version 2>/dev/null | awk '{print $2}' | head -n 1)"
else
  CURRENT_KIND=""
fi

if [[ -n "$CURRENT_KIND" ]] && [[ "$(normalize_version "$CURRENT_KIND")" == "$(normalize_version "$VERSION")" ]]; then
  echo "Kind ${CURRENT_KIND} is already installed. Skipping."
else
  curl -fsSL -o kind "https://kind.sigs.k8s.io/dl/${VERSION}/kind-${OS}-${ARCH}"
  chmod +x kind
  sudo install kind "$INSTALL_DIR/kind"
  rm -f kind
  echo "Kind installation completed."
fi

if [[ "$SKIP_KUBECTL" != "true" ]]; then
  install_kubectl "$OS" "$ARCH"
fi

if [[ "$SKIP_KUBECTL" != "true" ]]; then
  echo "kubectl is ready."
fi
echo "Next step: ./create-kind-cluster.sh"
