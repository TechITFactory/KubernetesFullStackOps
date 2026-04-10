# 4.5.1 Exposing an External IP Address to Access an Application in a Cluster

- Summary: Expose workload externally and validate public access path.
- Content:
  - Service type drives external access strategy.
  - Local labs use NodePort; cloud uses LoadBalancer.
  - Always confirm endpoints before traffic tests.
- Lab:

## Lab Steps (Linux)

```bash
kubectl create deployment web-ext --image=nginx:1.27
kubectl expose deployment web-ext --port=80 --type=NodePort
kubectl get svc web-ext
kubectl get endpoints web-ext
minikube service web-ext --url --profile k8sops
```

Success signal: URL reachable and endpoints populated.
Failure signal: service exists but no endpoint addresses.

EKS extension:

```bash
kubectl patch svc web-ext -p '{"spec":{"type":"LoadBalancer"}}'
kubectl get svc web-ext -w
```

Wait for `EXTERNAL-IP` assignment.
