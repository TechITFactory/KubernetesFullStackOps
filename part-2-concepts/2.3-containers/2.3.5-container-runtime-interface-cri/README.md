# 2.3.5 Container Runtime Interface (CRI)

- Summary: CRI is the contract between kubelet and the container runtime, which is why Kubernetes no longer speaks directly to Docker.
- Content: Connect CRI to runtime sockets, `crictl`, kubelet configuration, and troubleshooting at the node boundary.
- Lab: Inspect the runtime endpoint and compare kubelet/runtime alignment.

## Assets

- `scripts/inspect-cri-endpoint.sh`
- `yamls/cri-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/inspect-cri-endpoint.sh
kubectl apply -f yamls/cri-notes.yaml
kubectl get nodes -o wide
```

## Expected output

- Script reports a reachable CRI endpoint (or clearly explains what to fix on the node).
- Notes manifest applies for in-cluster documentation review.

## Video close - fast validation

```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system -o wide | head -n 15
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common CRI socket, `crictl`, and kubelet/runtime alignment failures.
