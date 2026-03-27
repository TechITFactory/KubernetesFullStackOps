#!/usr/bin/env bash
set -euo pipefail

CRIO_CONF_DIR="${CRIO_CONF_DIR:-/etc/crio/crio.conf.d}"

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "Run this script as root." >&2
    exit 1
  fi
}

package_installed() {
  dpkg -s "$1" >/dev/null 2>&1
}

require_root

export DEBIAN_FRONTEND=noninteractive

apt-get update

if ! package_installed cri-o; then
  apt-get install -y cri-o cri-o-runc
else
  echo "CRI-O package already installed. Skipping package install."
fi

mkdir -p "$CRIO_CONF_DIR"
cat > "$CRIO_CONF_DIR/02-cgroup-manager.conf" <<'EOF'
[crio.runtime]
cgroup_manager = "systemd"
conmon_cgroup = "pod"
EOF

systemctl enable --now crio
systemctl restart crio

echo "CRI-O is ready."
echo "CRI socket: /var/run/crio/crio.sock"
