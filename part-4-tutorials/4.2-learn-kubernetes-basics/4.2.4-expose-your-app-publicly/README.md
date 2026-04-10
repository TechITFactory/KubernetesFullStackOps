# 4.2.4 Expose Your App Publicly

- Summary: Expose an internal deployment through a Service and test access.
- Content:
  - Services provide stable network access to pods.
  - NodePort is useful for local labs.
  - Validate endpoints to confirm traffic targets healthy pods.
- Lab:

## Lab Steps (Linux)

```bash
kubectl expose deployment kubernetes-bootcamp --type=NodePort --port=8080
kubectl get service kubernetes-bootcamp
kubectl get endpoints kubernetes-bootcamp
minikube service kubernetes-bootcamp --url --profile k8sops
```

Success signal: service has endpoints and URL responds.
Failure signal: service exists but endpoints are empty.

EKS extension: replace NodePort with `type=LoadBalancer` and verify external IP.

## Transcript

[0:00-0:30] You will publish your app using a Kubernetes Service.  
[0:30-2:00] Pods are temporary; Service gives stable access.  
[2:00-7:00] Expose deployment, check service and endpoints, then test URL.  
[7:00-9:00] Empty endpoints means selector/pod readiness mismatch.  
[9:00-10:00] Service + endpoint validation is required before any traffic test.
