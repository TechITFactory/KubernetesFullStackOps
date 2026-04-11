# 3.15 Other Tasks

- Objective: Cover advanced operational tasks used in specialized workloads.
- Outcomes:
  - Extend kubectl with plugins for faster operations.
  - Manage HugePages and GPU scheduling basics.
  - Validate node capabilities before scheduling specialized pods.
- Notes:
  - Keep tasks practical and evidence-based.
  - Validate node support before workload apply.
  - Linux-only commands.

## Children

- 3.15.1 Extend kubectl with Plugins
- 3.15.2 Manage HugePages
- 3.15.3 Schedule GPUs

## Module Validation

```bash
kubectl get nodes -o wide
kubectl describe node <node-name> | grep -i -E "hugepages|nvidia|gpu|allocatable"
```
