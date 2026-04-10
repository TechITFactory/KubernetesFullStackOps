# 2.4.4 Managing Workloads

- Summary: Managing workloads is about safe rollout, inspection, scaling, pause/resume, and rollback behavior.
- Content: Focus on the operational lifecycle of workloads rather than only their definitions.
- Lab: Apply a workload, inspect rollout status, scale it, and perform a rollback.

## Assets

- `scripts/manage-workloads-demo.sh`
- `yamls/manage-workloads-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/manage-workloads-demo.sh
kubectl apply -f yamls/manage-workloads-demo.yaml
kubectl rollout status deployment/manage-workloads-demo --timeout=120s
```

## Expected output

- Script exercises safe inspection commands; Deployment becomes available.

## Video close - fast validation

```bash
kubectl get deploy manage-workloads-demo
kubectl rollout history deployment/manage-workloads-demo
kubectl get pods -l app=manage-workloads-demo -o wide
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common rollout pause, scaling, and rollback failures.
