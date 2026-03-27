# 1.3.4 Enforcing Pod Security Standards

- Summary: Pod Security Standards should be enforced intentionally with namespace labels and validated with safe and unsafe example workloads.
- Content: This section provides namespace labeling automation and sample manifests for `restricted` enforcement testing.
- Lab: Label a namespace for `restricted`, apply the compliant manifest successfully, then observe the non-compliant manifest fail admission.

## Assets

- `scripts/apply-pod-security-labels.sh`
- `yamls/restricted-namespace.yaml`
- `yamls/restricted-compliant-pod.yaml`
- `yamls/restricted-noncompliant-pod.yaml`
