#!/usr/bin/env bash
set -euo pipefail

check() {
  local name="$1"
  local required="$2"

  if command -v "$name" >/dev/null 2>&1; then
    echo "[OK] $name"
  elif [[ "$required" == "required" ]]; then
    echo "[MISSING] $name"
  else
    echo "[OPTIONAL] $name not found"
  fi
}

check kubectl required
check docker optional
check minikube optional
check kind optional
check helm optional

echo
echo "Current kubectl context:"
if command -v kubectl >/dev/null 2>&1; then
  kubectl config current-context 2>/dev/null || echo "[INFO] No current kubectl context is set yet"
fi
