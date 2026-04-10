# 3.10.1 Deploy and Access the Kubernetes Dashboard

- Summary: Install and access Kubernetes Dashboard securely.
- Content:
  - Dashboard is useful for quick visual inspection.
  - Access should be controlled and time-limited.
  - Keep CLI-first workflow as primary operational path.
- Lab:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl -n kubernetes-dashboard get pods,svc
kubectl -n kubernetes-dashboard create token admin-user
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard 10443:443
```

Open: `https://localhost:10443`

Success signal: dashboard login page opens and token works.
Failure signal: port-forward fails or token RBAC missing.

EKS extension: prefer AWS console + RBAC-integrated access patterns for production.
