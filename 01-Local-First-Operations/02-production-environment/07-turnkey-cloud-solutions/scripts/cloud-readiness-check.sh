#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: cloud-readiness-check.sh
# Lesson: 07-turnkey-cloud-solutions (see README)
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Prints [OK]/[MISSING] for CLIs: aws, gcloud, az, kubectl, helm, terraform, eksctl (with install hints).
#   2. Probes cloud auth: AWS sts, GCP active account, Azure account show — [OK]/[WARN] only.
#   3. Prints current kubectl context if kubectl exists — no resources created.
#
# Exit: always 0 from script.
# ------------------------------------------------------------------------------
set -euo pipefail

check_tool() {
  local name="$1"
  local install_hint="$2"
  if command -v "$name" >/dev/null 2>&1; then
    local version
    version="$("$name" --version 2>/dev/null | head -n1 || echo "unknown")"
    echo "[OK]      $name — $version"
  else
    echo "[MISSING] $name — install: $install_hint"
  fi
}

check_auth() {
  local name="$1"
  local cmd="$2"
  local hint="$3"
  if eval "$cmd" >/dev/null 2>&1; then
    echo "[OK]      $name auth"
  else
    echo "[WARN]    $name auth — $hint"
  fi
}

echo "==> Cloud CLI Readiness Check"
echo ""

echo "--- CLI Tools ---"
check_tool aws       "https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
check_tool gcloud    "https://cloud.google.com/sdk/docs/install"
check_tool az        "https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
check_tool kubectl   "https://kubernetes.io/docs/tasks/tools/"
check_tool helm      "https://helm.sh/docs/intro/install/"
check_tool terraform "https://developer.hashicorp.com/terraform/install"
check_tool eksctl    "https://eksctl.io/installation/"

echo ""
echo "--- Authentication ---"
check_auth "AWS"   "aws sts get-caller-identity"   "run 'aws configure' or set AWS_PROFILE"
check_auth "GCP"   "gcloud auth list --filter=status:ACTIVE --format='value(account)' | head -1 | grep -q ."  "run 'gcloud auth login'"
check_auth "Azure" "az account show"               "run 'az login'"

echo ""
echo "--- Kubernetes context ---"
if command -v kubectl >/dev/null 2>&1; then
  kubectl config current-context 2>/dev/null || echo "[INFO] No active kubectl context"
fi
