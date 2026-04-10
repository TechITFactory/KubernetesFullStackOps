# 3.2.5 Manage Memory, CPU, and API Resources

- Summary: Control resource usage and API fairness at cluster level.
- Content:
  - Use requests/limits, quotas, and limits to prevent contention.
  - Track node allocatable and usage trends continuously.
  - Validate that policy changes enforce expected behavior.
- Lab:

```bash
kubectl top nodes
kubectl top pods -A
kubectl get resourcequota -A
kubectl get limitrange -A
kubectl describe node <node-name> | grep -A10 -i Allocatable
```

Success signal: resource policies visible and usage stays within bounds.
Failure signal: repeated evictions or throttling without policy tuning.
