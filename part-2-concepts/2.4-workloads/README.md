# 2.4 Workloads

- Objective: Build a strong mental model for Pods and higher-level workload controllers, then connect that model to day-to-day operations.
- Outcomes: Explain pod internals, workload controller roles, lifecycle management, and autoscaling strategies.
- Notes: This section should constantly tie back to the reconciliation model: workloads define intent, controllers keep closing the gap.

## Children

- 2.4.1 Pods
- 2.4.2 Workload API
- 2.4.3 Workload Management
- 2.4.4 Managing Workloads
- 2.4.5 Autoscaling Workloads

## Module wrap - quick validation

```bash
kubectl get deploy,sts,ds,job,cronjob,hpa -A 2>/dev/null | head -n 40
kubectl get pods -A | head -n 30
kubectl get events -A --sort-by=.lastTimestamp | tail -n 25
```
