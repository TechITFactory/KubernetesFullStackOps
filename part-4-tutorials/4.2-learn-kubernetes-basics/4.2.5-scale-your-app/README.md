# 4.2.5 Scale Your App

- Summary: Scale replicas up/down and verify scheduler behavior.
- Content:
  - Scaling changes replica count, not application image.
  - Use rollout and pod distribution checks after scale.
  - Confirm service still routes to all healthy replicas.
- Lab:

## Lab Steps (Linux)

```bash
kubectl scale deployment/kubernetes-bootcamp --replicas=4
kubectl get deployment kubernetes-bootcamp
kubectl get pods -l app=kubernetes-bootcamp -o wide
kubectl get endpoints kubernetes-bootcamp
kubectl scale deployment/kubernetes-bootcamp --replicas=2
```

Success signal: desired/current/ready replicas match target count.
Failure signal: desired replicas increase but pods stay pending.

EKS extension: add HPA after static scaling to automate replica changes.

## Transcript

[0:00-0:30] You will scale app replicas and verify actual runtime state.  
[0:30-2:00] Scaling is about capacity and availability under load.  
[2:00-7:00] Scale up, verify pod count and endpoints, then scale down.  
[7:00-9:00] Pending pods usually indicate resource or scheduling constraints.  
[9:00-10:00] Always verify both deployment status and endpoints after scaling.
