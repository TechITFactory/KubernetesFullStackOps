# 2.2.5 Cloud Controller Manager

- Summary: The cloud controller manager isolates cloud-provider-specific logic from the core Kubernetes control plane.
- Content: Explain node initialization, route reconciliation, load balancer integration, and why self-managed clusters often do not use it.
- Lab: Review the responsibilities map and inspect whether your cluster is running a cloud controller manager.

## Assets

- `scripts/inspect-cloud-controller-manager.sh`
- `yamls/cloud-controller-manager-responsibilities.yaml`
