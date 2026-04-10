# 2.4.3 Workload Management

- Summary: Different workload controllers exist because different availability, identity, and execution guarantees are needed.
- Content: This section walks through the major controllers and when each one is the right fit.
- Lab: Deploy examples of Deployments, StatefulSets, and Jobs, then compare their behavior.

## Children

- `2.4.3.1 Deployments`
- `2.4.3.2 ReplicaSet`
- `2.4.3.3 StatefulSets`
- `2.4.3.4 DaemonSet`
- `2.4.3.5 Jobs`
- `2.4.3.6 Automatic Cleanup for Finished Jobs`
- `2.4.3.7 CronJob`
- `2.4.3.8 ReplicationController`

## Module wrap - quick validation

```bash
kubectl get deploy,sts,ds,job,cronjob,rc -A 2>/dev/null | head -n 40
kubectl get pods -A | head -n 25
```
