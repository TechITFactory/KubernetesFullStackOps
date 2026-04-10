# 3.4 Monitoring, Logging, and Debugging

- Objective: Diagnose workload and cluster problems quickly using core Kubernetes signals.
- Outcomes:
  - Use logs, events, metrics, and describe output in a repeatable debug flow.
  - Isolate whether issue is app, platform, networking, or scheduling.
  - Apply fast recovery actions and verify cluster stability.
- Notes:
  - Practical-first, no-fluff.
  - Linux commands only.
  - Same workflows apply to local clusters and EKS.

## Children

- 3.4.1 Logging in Kubernetes
- 3.4.2 Monitoring in Kubernetes
- 3.4.3 Troubleshooting Applications
- 3.4.4 Troubleshooting Clusters

## Debug Baseline Commands

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get events -A --sort-by=.lastTimestamp | tail -n 40
```
