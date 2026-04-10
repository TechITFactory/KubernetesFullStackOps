# 4.8.3 Explore Termination Behavior for Pods And Their Endpoints

- Summary: Observe how pod termination affects service endpoints and traffic.
- Content:
  - Endpoint updates are critical during rolling updates.
  - Graceful termination prevents dropped requests.
  - Validate endpoint removal timing when pods stop.
- Lab:

```bash
kubectl create deployment term-demo --image=nginx:1.27 --replicas=2
kubectl expose deployment term-demo --name=term-svc --port=80
kubectl get endpoints term-svc -w
kubectl delete pod -l app=term-demo --grace-period=30
```

In another shell:

```bash
kubectl get pod -l app=term-demo -w
```

Success signal: endpoints update as pods terminate/recreate.
Failure signal: stale endpoints continue receiving traffic after pod exit.

EKS extension: combine with readiness and preStop hooks for zero-downtime updates.
