# 4.5 Stateless Applications

- Objective: Deploy and expose stateless workloads using production-safe basics.
- Outcomes:
  - Deploy stateless app patterns with Deployments and Services.
  - Expose traffic safely and verify endpoint health.
  - Understand practical differences between local and cloud exposure.
- Notes:
  - Keep flow practical: deploy, expose, verify, fix.
  - Linux-only command examples.
  - Include EKS load balancer extension patterns.

## Children

- 4.5.1 Exposing an External IP Address to Access an Application in a Cluster
- 4.5.2 Example: Deploying PHP Guestbook Application with Redis

## Module Health Check

```bash
kubectl get deploy,pod,svc
kubectl get endpoints
```
