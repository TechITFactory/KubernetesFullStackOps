# 4.4 Security Tutorials

- Objective: Apply practical security controls that teams use in production clusters.
- Outcomes:
  - Enforce Pod Security Standards at cluster and namespace scopes.
  - Validate security settings with allow/deny behavior.
  - Understand where AppArmor and seccomp fit.
- Notes:
  - No security fluff. Focus on enforce, verify, and troubleshoot.
  - Linux-only commands and manifests.
  - Reuse same checks on EKS clusters.

## Children

- 4.4.1 Apply Pod Security Standards at the Cluster Level
- 4.4.2 Apply Pod Security Standards at the Namespace Level
- 4.4.3 Restrict a Container's Access to Resources with AppArmor
- 4.4.4 Restrict a Container's Syscalls with seccomp

## Security Validation Loop

```bash
kubectl auth can-i create pods --all-namespaces
kubectl get ns --show-labels
kubectl get events -A --sort-by=.lastTimestamp | tail -n 30
```
