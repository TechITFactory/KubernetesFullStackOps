# 4.7.3 Install Drivers and Allocate Devices with DRA

- Summary: Learn Dynamic Resource Allocation workflow for specialized hardware.
- Content:
  - DRA decouples device allocation logic from built-in resource types.
  - Driver + claim model provides more flexible scheduling.
  - Start with discovery and CRD validation before claims.
- Lab:

```bash
kubectl api-resources | grep -i resourceclaim
kubectl get crd | grep -i dra
kubectl get nodes -o wide
kubectl describe node | grep -i -E "allocatable|capacity"
```

Success signal: required DRA resources are available in cluster.
Failure signal: missing CRDs/resources for DRA workflow.

EKS extension: DRA readiness depends on cluster version and addon support.
