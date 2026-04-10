# 4.8.1 Connecting Applications with Services

- Summary: Connect two applications using Kubernetes Service discovery.
- Content:
  - Services provide stable DNS and endpoint routing.
  - Labels/selectors decide backend pod membership.
  - Validate connectivity from one pod to another.
- Lab:

```bash
kubectl create deployment backend --image=nginx:1.27
kubectl expose deployment backend --name=backend-svc --port=80
kubectl run client --image=busybox:1.36 -it --rm --restart=Never -- /bin/sh -c "wget -qO- http://backend-svc"
kubectl get svc,endpoints backend-svc
```

Success signal: client pod fetches backend response.
Failure signal: DNS resolves but endpoints are empty.

EKS extension: same service discovery inside cluster; external access via Ingress/LB.
