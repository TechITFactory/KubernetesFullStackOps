# 4.6 Stateful Applications

- Objective: Run and operate stateful workloads with persistence and stable identity.
- Outcomes:
  - Use StatefulSets and persistent volumes correctly.
  - Validate storage binding and pod identity behavior.
  - Troubleshoot common stateful workload failures.
- Notes:
  - Focus on deploy, verify, recover workflow.
  - Linux-only labs with local-first approach and EKS extension notes.
  - No fluff theory; only what is needed to run the lab.

## Children

- 4.6.1 StatefulSet Basics
- 4.6.2 Example: Deploying WordPress and MySQL with Persistent Volumes
- 4.6.3 Example: Deploying Cassandra with a StatefulSet
- 4.6.4 Running ZooKeeper, A Distributed System Coordinator

## Module Health Check

```bash
kubectl get statefulset,pod,pvc
kubectl get events --sort-by=.lastTimestamp | tail -n 30
```
