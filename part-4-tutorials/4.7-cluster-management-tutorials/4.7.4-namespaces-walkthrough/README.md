# 4.7.4 Namespaces Walkthrough

- Summary: Use namespaces to isolate teams, workloads, and policies.
- Content:
  - Namespaces are the base boundary for multi-team operations.
  - Use labels, quotas, and RBAC per namespace.
  - Verify workload visibility and access control per namespace.
- Lab:

```bash
kubectl create ns team-a
kubectl create ns team-b
kubectl create deployment app-a -n team-a --image=nginx:1.27
kubectl create deployment app-b -n team-b --image=nginx:1.27
kubectl get deploy -A
kubectl config set-context --current --namespace=team-a
kubectl get pods
```

Success signal: resources are isolated by namespace.
Failure signal: accidental deployment in wrong namespace due to context mismatch.

EKS extension: map IAM/RBAC roles per namespace for team ownership.
