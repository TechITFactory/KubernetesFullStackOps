# 2.2.4 Leases

- Summary: Leases reduce heartbeat churn and support leader election, making them an important but often overlooked control-plane primitive.
- Content: Show how node heartbeats use Lease objects and how leader election uses similar mechanisms for coordination.
- Lab: Inspect leases in the cluster and correlate them with nodes or control-plane components.

## Assets

- `scripts/inspect-leases.sh`
- `yamls/lease-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/inspect-leases.sh
kubectl get lease -A
kubectl describe lease -n kube-node-lease "$(kubectl get lease -n kube-node-lease -o jsonpath='{.items[0].metadata.name}')"
```

## Expected output

- Lease objects appear for nodes (and leader-election participants where used).
- `renewTime` changes over time, reflecting heartbeat/leadership refresh.

## Video close - fast validation

```bash
kubectl get lease -n kube-node-lease
kubectl get lease -A | head -n 20
kubectl get nodes
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common missing-lease, stale-renewTime, and node-heartbeat issues.
