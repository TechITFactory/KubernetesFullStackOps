# 3.2.7 Access Clusters Using the Kubernetes API

- Summary: Access Kubernetes API directly for diagnostics and automation.
- Content:
  - API access enables scripted operations beyond kubectl defaults.
  - Use current context credentials securely.
  - Validate response and permissions before write calls.
- Lab:

```bash
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'; echo
kubectl get --raw /healthz
kubectl get --raw /version
kubectl auth can-i get pods --all-namespaces
```

Success signal: API endpoints return healthy responses.
Failure signal: auth failures or TLS trust errors.
