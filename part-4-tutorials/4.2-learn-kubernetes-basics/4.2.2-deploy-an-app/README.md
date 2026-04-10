# 4.2.2 Deploy an App

- Summary: Deploy your first app with a Deployment and confirm pod readiness.
- Content:
  - Deployments manage desired state and self-healing.
  - Always check rollout status after apply/create.
  - Read pod logs early when status is not healthy.
- Lab:

## Lab Steps (Linux)

```bash
kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
kubectl get deployments
kubectl rollout status deployment/kubernetes-bootcamp
kubectl get pods -l app=kubernetes-bootcamp -o wide
```

Success signal: rollout completes and pod status is `Running`.
Failure signal: image pull or crash errors in pod events.

EKS extension: same deployment commands work unchanged on EKS clusters.

## Transcript

[0:00-0:30] You will deploy an app and verify rollout.  
[0:30-2:00] Deployment keeps your app replicas aligned with desired state.  
[2:00-7:00] Create deployment, check it exists, wait for rollout, verify pod status.  
[7:00-9:00] For failures, inspect `kubectl describe pod` and container logs.  
[9:00-10:00] Deploy + rollout status is a core daily workflow in real teams.
