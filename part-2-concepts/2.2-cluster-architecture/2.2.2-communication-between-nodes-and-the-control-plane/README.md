# 2.2.2 Communication between Nodes and the Control Plane

- Summary: Node-to-control-plane communication is mostly kubelet-driven and API-based, which is central to understanding access patterns and security boundaries.
- Content: Cover kubelet registration, heartbeats, API server access, certificate use, and how node agents avoid direct dependency on the scheduler or controller-manager.
- Lab: Inspect node status updates, leases, and kubelet-facing communication surfaces.

## Assets

- `scripts/inspect-node-control-plane-communication.sh`
- `yamls/node-control-plane-flow.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/inspect-node-control-plane-communication.sh
kubectl get nodes
kubectl get lease -n kube-node-lease
```

## Expected output

- Node lease objects are visible and correlate with node names.
- Node heartbeats and status updates can be observed from API objects/events.

## Video close - fast validation

```bash
kubectl get lease -n kube-node-lease | head -n 20
kubectl get events -n kube-system --sort-by=.lastTimestamp | tail -n 20
kubectl get nodes -o wide
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common node registration, lease heartbeat, and API communication failures.
