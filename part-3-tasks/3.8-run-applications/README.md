# 3.8 Run Applications

- Objective: Deploy, scale, and operate application workloads reliably.
- Outcomes:
  - Run stateless and stateful workloads with correct controllers.
  - Apply availability patterns like HPA and disruption budgets.
  - Access in-cluster APIs safely from workloads.
- Notes:
  - Command-first labs with clear validation outputs.
  - Emphasis on rollout safety and runtime checks.
  - Local-first workflows with EKS extensions where relevant.

## Children

- 3.8.1 Run a Stateless Application Using a Deployment
- 3.8.2 Run a Single-Instance Stateful Application
- 3.8.3 Run a Replicated Stateful Application
- 3.8.4 Scale a StatefulSet
- 3.8.5 Delete a StatefulSet
- 3.8.6 Force Delete StatefulSet Pods
- 3.8.7 HorizontalPodAutoscaler Walkthrough
- 3.8.8 Specifying a Disruption Budget for your Application
- 3.8.9 Accessing the Kubernetes API from a Pod

## Module Health Checks

```bash
kubectl get deploy,statefulset,pod -A
kubectl get hpa,pdb -A
kubectl get events -A --sort-by=.lastTimestamp | tail -n 30
```
