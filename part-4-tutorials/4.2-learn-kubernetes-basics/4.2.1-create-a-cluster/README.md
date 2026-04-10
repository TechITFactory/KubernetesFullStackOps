# 4.2.1 Create a Cluster

- Summary: Create a local Kubernetes cluster and verify control-plane health.
- Content:
  - Use Minikube or Kind for fast local practice.
  - Validate cluster readiness before deploying apps.
  - Treat health checks as mandatory first step.
- Lab:

## Lab Steps (Linux)

```bash
minikube start --driver=docker --profile k8sops
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -n kube-system
```

Success signal: node is `Ready` and system pods are mostly `Running`.
Failure signal: repeated `CrashLoopBackOff` in `kube-system`.

EKS extension: same readiness checks apply after `aws eks update-kubeconfig`.

## Transcript

[0:00-0:30] You will create a cluster and verify it is healthy.  
[0:30-2:00] Cluster first, app second. Always verify control plane before deployment.  
[2:00-7:00] Run start command, then `cluster-info`, then node and system pod checks.  
[7:00-9:00] If pods fail, inspect `kubectl describe pod` and events.  
[9:00-10:00] Cluster health checks are your baseline for every lab and job task.
