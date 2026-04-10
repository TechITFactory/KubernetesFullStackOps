# 3.10.6 Connect a Frontend to a Backend Using Services

- Summary: Wire frontend and backend workloads through Kubernetes Services.
- Content:
  - Services provide stable DNS-based connectivity between tiers.
  - Verify service selectors and endpoints before app testing.
  - Debug by checking frontend env/config and backend reachability.
- Lab:

```bash
kubectl create ns app-connect
kubectl create deployment backend -n app-connect --image=nginx:1.27
kubectl expose deployment backend -n app-connect --name=backend --port=80
kubectl run frontend -n app-connect --image=busybox:1.36 --restart=Never -- sleep 3600
kubectl exec -n app-connect frontend -- wget -qO- http://backend
kubectl get svc,endpoints -n app-connect
```

Success signal: frontend pod reaches backend service by DNS name.
Failure signal: frontend request timeout or no endpoints.

EKS extension: same in-cluster pattern with optional Ingress/ALB for external frontend access.
