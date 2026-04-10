# 2.1.1 Kubernetes Components

- Summary: Understand how control-plane and node components collaborate to run workloads and reconcile desired state.
- Content: This section covers the API server, etcd, scheduler, controller manager, kubelet, kube-proxy, and runtime from an operator’s point of view.
- Lab: Use the scripts and manifests here to list system components and map them to their roles in the cluster.

## Assets

- `scripts/inspect-k8s-components.sh`
- `yamls/components-map.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/inspect-k8s-components.sh
kubectl get pods -n kube-system -o wide
kubectl apply -f yamls/components-map.yaml
```

## Expected output

- Control-plane and node component mapping is visible from `kube-system` pods and node state.
- The component map manifest applies without schema errors.

## Video close - fast validation

```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system
kubectl get componentstatuses 2>/dev/null || true
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common component visibility and API connectivity failures.
