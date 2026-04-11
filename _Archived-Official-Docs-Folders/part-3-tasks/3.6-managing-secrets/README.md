# 3.6 Managing Secrets

- Objective: Manage sensitive configuration securely in Kubernetes workloads.
- Outcomes:
  - Create, apply, and consume secrets safely.
  - Validate secret references in pods and deployments.
  - Avoid secret leakage through logs and manifests.
- Notes:
  - Use least-privilege access and namespace scoping.
  - Prefer external secret systems for production when available.
  - Linux practical commands only.

## Children

- 3.6.1 Managing Secrets Using kubectl
- 3.6.2 Managing Secrets Using Configuration File
- 3.6.3 Managing Secrets Using Kustomize

## Safety Checks

```bash
kubectl get secrets
kubectl auth can-i get secrets --namespace default
kubectl describe pod <pod-name> | grep -i secret
```
