#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: check-k8s-pki.sh
# Lesson: 03.5-pki-certificates-and-requirements (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Requires openssl. PKI_DIR default /etc/kubernetes/pki — must exist.
#   2. find all .crt/.pem under PKI_DIR; for each, openssl x509 -subject -issuer -dates and SANs
#      (read-only; prints to stdout).
#
# Exit: 0; 1 if openssl missing or PKI_DIR missing.
# ------------------------------------------------------------------------------
set -euo pipefail

PKI_DIR="${PKI_DIR:-/etc/kubernetes/pki}"

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl was not found in PATH." >&2
  exit 1
fi

if [[ ! -d "$PKI_DIR" ]]; then
  echo "PKI directory not found: $PKI_DIR" >&2
  exit 1
fi

find "$PKI_DIR" -type f \( -name '*.crt' -o -name '*.pem' \) | sort | while read -r cert; do
  echo "==> $cert"
  openssl x509 -in "$cert" -noout -subject -issuer -dates || true
  openssl x509 -in "$cert" -noout -ext subjectAltName 2>/dev/null || true
  echo
done
