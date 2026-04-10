# 2.2.5 Cloud Controller Manager

- Summary: The cloud controller manager isolates cloud-provider-specific logic from the core Kubernetes control plane.
- Content: Explain node initialization, route reconciliation, load balancer integration, and why self-managed clusters often do not use it.
- Lab: Review the responsibilities map and inspect whether your cluster is running a cloud controller manager.

## Assets

- `scripts/inspect-cloud-controller-manager.sh`
- `yamls/cloud-controller-manager-responsibilities.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/inspect-cloud-controller-manager.sh
kubectl get pods -A | grep -i cloud-controller || true
kubectl apply -f yamls/cloud-controller-manager-responsibilities.yaml
```

## Expected output

- You can determine whether CCM is present in the current cluster.
- Responsibilities map is available for architecture review and provider comparison.

## Video close - fast validation

```bash
kubectl get nodes -o wide
kubectl get pods -A | grep -Ei 'cloud-controller|ccm' || true
kubectl get svc -A
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common CCM absence, provider-integration, and node-initialization issues.
