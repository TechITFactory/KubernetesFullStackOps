#!/usr/bin/env bash
set -euo pipefail

ETCD_VERSION="${ETCD_VERSION:-v3.5.13}"
ETCD_DATA_DIR="${ETCD_DATA_DIR:-/var/lib/etcd}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
ETCD_PKI_DIR="${ETCD_PKI_DIR:-/etc/kubernetes/pki/etcd}"

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "Run this script as root on each etcd node." >&2
    exit 1
  fi
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Required command '$1' not found in PATH." >&2
    exit 1
  }
}

require_root
require_cmd curl
require_cmd tar

# Install etcd binaries if not already present
if [[ -x "$INSTALL_DIR/etcd" ]]; then
  CURRENT="$("$INSTALL_DIR/etcd" --version 2>/dev/null | head -n1 | awk '{print $3}')"
  if [[ "$CURRENT" == "${ETCD_VERSION#v}" ]]; then
    echo "etcd ${CURRENT} already installed. Skipping."
  else
    echo "etcd ${CURRENT} found but target is ${ETCD_VERSION}. Reinstalling."
    INSTALL_ETCD=true
  fi
else
  INSTALL_ETCD=true
fi

if [[ "${INSTALL_ETCD:-false}" == "true" ]]; then
  OS="linux"
  ARCH="$(uname -m)"
  [[ "$ARCH" == "x86_64" ]] && ARCH="amd64"
  [[ "$ARCH" == "aarch64" ]] && ARCH="arm64"

  TARBALL="etcd-${ETCD_VERSION}-${OS}-${ARCH}.tar.gz"
  curl -fsSL -o "/tmp/$TARBALL" \
    "https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/${TARBALL}"
  tar -xzf "/tmp/$TARBALL" -C /tmp
  install "/tmp/etcd-${ETCD_VERSION}-${OS}-${ARCH}/etcd" "$INSTALL_DIR/etcd"
  install "/tmp/etcd-${ETCD_VERSION}-${OS}-${ARCH}/etcdctl" "$INSTALL_DIR/etcdctl"
  rm -rf "/tmp/$TARBALL" "/tmp/etcd-${ETCD_VERSION}-${OS}-${ARCH}"
  echo "etcd ${ETCD_VERSION} installed."
fi

# Create data directory
mkdir -p "$ETCD_DATA_DIR"
chmod 700 "$ETCD_DATA_DIR"

# Create PKI directory (kubeadm will populate certs here)
mkdir -p "$ETCD_PKI_DIR"

echo ""
echo "etcd binary ready at: $INSTALL_DIR/etcd"
echo "Data directory:        $ETCD_DATA_DIR"
echo "PKI directory:         $ETCD_PKI_DIR"
echo ""
echo "Next steps:"
echo "  1. Use kubeadm to generate etcd CA and member certificates into $ETCD_PKI_DIR"
echo "  2. Create a systemd unit for etcd pointing to these certs and $ETCD_DATA_DIR"
echo "  3. Update external-etcd-cluster-plan.yaml with actual endpoints and cert paths"
echo "  4. Run kubeadm init with the external etcd config on the first control-plane node"
