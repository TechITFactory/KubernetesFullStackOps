# 4.6.2 Example: Deploying WordPress and MySQL with Persistent Volumes

- Summary: Deploy WordPress + MySQL and validate persistent data behavior.
- Content:
  - Multi-tier stateful stack needs storage and service wiring.
  - Validate backend DB first, then frontend app.
  - Persisted data should survive pod restarts.
- Lab:

```bash
kubectl apply -f https://k8s.io/examples/application/wordpress/mysql-deployment.yaml
kubectl apply -f https://k8s.io/examples/application/wordpress/wordpress-deployment.yaml
kubectl get deploy,pod,svc,pvc
kubectl get events --sort-by=.lastTimestamp | tail -n 30
```

Success signal: MySQL and WordPress pods are running, PVCs bound.
Failure signal: WordPress starts but DB connection fails.

EKS extension: use managed database for production-like architecture, keep WordPress on cluster.

## Transcript

[0:00-0:30] You will run a realistic app + database pair with persistent storage.  
[0:30-2:00] Validate dependencies in order: database first, app second.  
[2:00-7:00] Apply manifests, inspect pods/services/PVCs, then test access.  
[7:00-9:00] If app fails, check DB readiness and service endpoints.  
[9:00-10:00] Stateful dependencies require strict verification sequencing.
