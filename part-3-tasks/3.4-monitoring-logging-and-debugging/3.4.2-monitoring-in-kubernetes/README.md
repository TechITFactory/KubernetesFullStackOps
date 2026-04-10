# 3.4.2 Monitoring in Kubernetes

- Summary: Monitor cluster and workload health using Kubernetes-native signals.
- Content:
  - Start with `metrics-server`, then dashboards/alerts.
  - Track node and pod usage continuously.
  - Validate resource pressure before incidents escalate.
- Lab:

```bash
kubectl top nodes
kubectl top pods -A
kubectl get --raw /metrics | head -n 20
kubectl get events -A --sort-by=.lastTimestamp | tail -n 30
```

Success signal: usage metrics visible and actionable.
Failure signal: `kubectl top` unavailable due to missing metrics pipeline.
