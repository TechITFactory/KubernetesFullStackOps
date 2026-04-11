#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: verify-2-5-1-service-lesson.sh
# Lesson: 2.5.1 Service
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Waits for Deployment echo in namespace svc-demo to become available.
#   2. Checks Service echo has a ClusterIP (not headless).
#   3. Counts Endpoint addresses for the Service (expects 2 ready backends).
#
# Prerequisite: kubectl apply -f yamls/service-clusterip-demo.yaml
# Exit: 0 on success.
# ------------------------------------------------------------------------------
set -euo pipefail

NS="${NS:-svc-demo}"

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

if ! kubectl get ns "$NS" &>/dev/null; then
  echo "FAIL: namespace $NS not found. Run: kubectl apply -f yamls/service-clusterip-demo.yaml" >&2
  exit 1
fi

kubectl -n "$NS" wait --for=condition=available "deploy/echo" --timeout=180s

want=$(kubectl -n "$NS" get deploy echo -o jsonpath='{.spec.replicas}')
ready=$(kubectl -n "$NS" get deploy echo -o jsonpath='{.status.readyReplicas}')
ready="${ready:-0}"
if [[ "$ready" != "$want" ]]; then
  echo "FAIL: Deployment echo ready=$ready want=$want" >&2
  exit 1
fi

cip=$(kubectl -n "$NS" get svc echo -o jsonpath='{.spec.clusterIP}' 2>/dev/null || true)
if [[ -z "$cip" || "$cip" == "None" ]]; then
  echo "FAIL: Service echo should have a ClusterIP (got: ${cip:-empty})" >&2
  exit 1
fi

# Endpoint addresses (classic Endpoints object; still populated alongside EndpointSlices on supported clusters)
addrs=0
if out=$(kubectl -n "$NS" get endpoints echo -o jsonpath='{range .subsets[*].addresses[*]}{.ip}{"\n"}{end}' 2>/dev/null); then
  addrs=$(echo "$out" | grep -c . || true)
fi

if [[ "$addrs" -lt "$want" ]]; then
  # Fallback: count ready endpoints via EndpointSlice
  if kubectl get endpointslices -n "$NS" &>/dev/null; then
    es_addrs=$(kubectl -n "$NS" get endpointslices -l kubernetes.io/service-name=echo -o jsonpath='{range .items[*].endpoints[*].addresses[*]}{.}{"\n"}{end}' 2>/dev/null | grep -c . || true)
    if [[ "$es_addrs" -ge "$want" ]]; then
      addrs=$es_addrs
    fi
  fi
fi

if [[ "$addrs" -lt "$want" ]]; then
  echo "FAIL: expected at least $want endpoint addresses for svc/echo (got $addrs)" >&2
  kubectl -n "$NS" get endpoints echo -o yaml | tail -n 30 >&2
  kubectl -n "$NS" get endpointslices -l kubernetes.io/service-name=echo -o wide 2>/dev/null >&2 || true
  exit 1
fi

echo "verify-2-5-1-service-lesson: OK (ns=$NS clusterIP=$cip backends>=$want)"
