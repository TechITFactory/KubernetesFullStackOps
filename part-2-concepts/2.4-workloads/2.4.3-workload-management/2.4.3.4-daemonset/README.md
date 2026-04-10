# 2.4.3.4 DaemonSet

- Summary: DaemonSets ensure a pod runs on matching nodes, which makes them ideal for node-local agents.
- Content: Tie this to log shippers, observability agents, and node services.
- Lab: Apply the DaemonSet demo and inspect pod placement.

## Assets

- `yamls/daemonset-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/daemonset-demo.yaml
kubectl rollout status daemonset/daemonset-demo --timeout=180s
kubectl get pods -l app=daemonset-demo -o wide
```

## Expected output

- One pod per schedulable node (or expected count on single-node clusters).

## Video close - fast validation

```bash
kubectl get ds daemonset-demo
kubectl get pods -l app=daemonset-demo -o wide
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common taint/toleration and node selector mismatches for DaemonSets.
