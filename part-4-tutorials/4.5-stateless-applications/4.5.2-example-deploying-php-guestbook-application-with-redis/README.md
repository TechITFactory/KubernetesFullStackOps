# 4.5.2 Example: Deploying PHP Guestbook Application with Redis

- Summary: Deploy a multi-tier stateless web app with Redis backend.
- Content:
  - Multi-tier apps test service discovery and dependency wiring.
  - Validate each tier before testing end-to-end behavior.
  - Troubleshoot by layer: deployment, service, endpoints, logs.
- Lab:

## Lab Steps (Linux)

```bash
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-leader-deployment.yaml
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-leader-service.yaml
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-follower-deployment.yaml
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-follower-service.yaml
kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml
kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml
```

Verify:

```bash
kubectl get deploy,pod,svc
kubectl get endpoints
```

Expose frontend locally:

```bash
minikube service frontend --url --profile k8sops
```

Success signal: frontend reachable and entries persist through Redis.
Failure signal: frontend up but cannot read/write entries due to Redis/service issues.

EKS extension: set frontend service type to `LoadBalancer` for internet access.
