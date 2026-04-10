# 3.10.2 Accessing Clusters

- Summary: Configure and verify secure cluster access with kubeconfig contexts.
- Content:
  - Access control starts with correct kubeconfig and identity.
  - Context switching prevents accidental changes in wrong cluster.
  - Always confirm context before write operations.
- Lab:

```bash
kubectl config get-contexts
kubectl config current-context
kubectl cluster-info
kubectl auth can-i get pods --all-namespaces
```

Switch context:

```bash
kubectl config use-context <context-name>
kubectl config current-context
```

Success signal: expected context active and permissions validated.
Failure signal: auth errors or accidental operations in wrong cluster.

EKS extension: use `aws eks update-kubeconfig --name <cluster>` per environment.
