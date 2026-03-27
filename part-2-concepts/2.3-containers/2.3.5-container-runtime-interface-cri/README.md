# 2.3.5 Container Runtime Interface (CRI)

- Summary: CRI is the contract between kubelet and the container runtime, which is why Kubernetes no longer speaks directly to Docker.
- Content: Connect CRI to runtime sockets, `crictl`, kubelet configuration, and troubleshooting at the node boundary.
- Lab: Inspect the runtime endpoint and compare kubelet/runtime alignment.

## Assets

- `scripts/inspect-cri-endpoint.sh`
- `yamls/cri-notes.yaml`
