#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: manage-workloads-demo.sh
# Lesson: 2.4.4 Managing workloads
#
# WHAT THIS DOES WHEN YOU RUN IT
#   1. Applies Deployment manage-workloads-demo (2 replicas, nginx:1.27).
#   2. Waits for rollout available.
#   3. Scales to 3 replicas; waits for rollout.
#   4. Changes container image to nginx:1.26 (new ReplicaSet / revision); waits.
#   5. Prints rollout history, then kubectl rollout undo (back to 1.27); waits.
#
# Re-running on the same cluster: safe if the Deployment is already at the final
# state (3 replicas, nginx:1.27). If stuck mid-demo, delete the Deployment and re-run.
#
# Exit: 0 if all rollouts succeed; non-zero on kubectl errors.
# ------------------------------------------------------------------------------
set -euo pipefail

command -v kubectl >/dev/null 2>&1 || { echo "FAIL: kubectl not in PATH" >&2; exit 1; }

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
YAML="$HERE/../yamls/manage-workloads-demo.yaml"
DEP="manage-workloads-demo"

kubectl apply -f "$YAML"
kubectl rollout status "deployment/$DEP" --timeout=180s

echo "==> scale 2 -> 3"
kubectl scale "deployment/$DEP" --replicas=3
kubectl rollout status "deployment/$DEP" --timeout=180s

echo "==> new revision (image nginx:1.27 -> nginx:1.26)"
kubectl set image "deployment/$DEP" nginx=nginx:1.26 --request-timeout=2m
kubectl rollout status "deployment/$DEP" --timeout=180s

echo "==> rollout history (expect at least 2 revisions)"
kubectl rollout history "deployment/$DEP"

echo "==> rollback to previous revision (expect nginx:1.27)"
kubectl rollout undo "deployment/$DEP"
kubectl rollout status "deployment/$DEP" --timeout=180s

img=$(kubectl get "deployment/$DEP" -o jsonpath='{.spec.template.spec.containers[0].image}')
echo "==> done: template image is now: $img"
