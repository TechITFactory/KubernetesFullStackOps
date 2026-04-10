# 3.13.2 Perform a Rolling Update on a DaemonSet

- Summary: Roll out DaemonSet updates safely across all nodes.
- Content:
  - DaemonSets run one pod per eligible node.
  - Rolling update replaces pods gradually per strategy.
  - Verify node coverage before and after update.
- Lab:

```bash
kubectl get daemonset -A
kubectl set image daemonset/<name> <container>=<new-image> -n <namespace>
kubectl rollout status daemonset/<name> -n <namespace>
kubectl get pods -n <namespace> -l <label-selector> -o wide
```

Success signal: desired/current/ready counts converge after rollout.
Failure signal: some node daemon pods stay old or crash.

EKS extension: monitor node-group specific daemon behavior during rolling changes.
