# 2.2.1 Nodes

- Summary: Nodes are the execution boundary for Kubernetes workloads and the place where kubelet, kube-proxy, and the runtime turn desired state into running containers.
- Content: Focus on node roles, conditions, allocatable resources, taints, labels, and the operational difference between control-plane and worker nodes.
- Lab: Inspect nodes, conditions, capacity, allocatable resources, and runtime metadata.

## Assets

- `scripts/inspect-nodes.sh`
- `yamls/node-observation-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/inspect-nodes.sh
kubectl get nodes -o wide
kubectl describe node "$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')" | sed -n '1,80p'
```

## Expected output

- Node `Ready` state, roles, and runtime details are visible.
- Capacity/allocatable and condition blocks are inspectable from `kubectl describe node`.

## Video close - fast validation

```bash
kubectl get nodes -o wide
kubectl top nodes 2>/dev/null || true
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common node readiness, kubelet, and resource-reporting failures.
