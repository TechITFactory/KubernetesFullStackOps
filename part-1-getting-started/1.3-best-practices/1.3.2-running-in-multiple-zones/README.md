# 1.3.2 Running in Multiple Zones

- Summary: Multi-zone Kubernetes improves resilience only when nodes, workloads, and storage choices are aligned with real failure domains.
- Content: This section includes zone labeling checks, spread constraints, and anti-affinity examples to prevent all replicas from landing in a single zone.
- Lab: Label nodes by zone, deploy the sample workload, and confirm replicas distribute across availability zones.

## Assets

- `scripts/check-multi-zone-labels.sh`
- `yamls/multi-zone-deployment.yaml`
- `yamls/storage-zone-notes.yaml`
