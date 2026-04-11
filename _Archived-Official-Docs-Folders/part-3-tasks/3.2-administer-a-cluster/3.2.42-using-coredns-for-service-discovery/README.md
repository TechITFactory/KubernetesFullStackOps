# 3.2.42 Using CoreDNS for Service Discovery

- Summary: Validate service discovery flow backed by CoreDNS.
- Content:
  - CoreDNS resolves service names to cluster IPs.
  - Service discovery requires healthy services and endpoints.
  - Debug by checking DNS response plus endpoint state.
- Lab:

```bash
kubectl create deployment sd-backend --image=nginx:1.27
kubectl expose deployment sd-backend --name=sd-backend --port=80
kubectl run sd-client --image=busybox:1.36 -it --rm --restart=Never -- nslookup sd-backend.default.svc.cluster.local
kubectl get svc sd-backend
kubectl get endpoints sd-backend
```

Success signal: DNS resolves service name and endpoint exists.
Failure signal: DNS resolves but service has no endpoints.

EKS extension: same service discovery behavior; validate in multi-namespace app layouts.
