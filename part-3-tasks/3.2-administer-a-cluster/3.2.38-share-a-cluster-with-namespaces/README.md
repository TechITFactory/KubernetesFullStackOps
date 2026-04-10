# 3.2.38 Share a Cluster with Namespaces

- Summary: Isolate teams in a shared cluster using namespaces and quotas.
- Content:
  - Namespaces separate resources, policies, and access.
  - Add quotas and role bindings for controlled multi-tenancy.
  - Validate isolation with context switching and permissions.
- Lab:

```bash
kubectl create ns team1
kubectl create ns team2
kubectl create quota team1-quota -n team1 --hard=pods=10,requests.cpu=2
kubectl create quota team2-quota -n team2 --hard=pods=10,requests.cpu=2
kubectl get ns
kubectl describe quota -n team1
```

Success signal: each namespace has independent quotas/resources.
Failure signal: teams can exceed limits or interfere with each other.

EKS extension: map IAM roles to namespace-scoped RBAC for team access.
