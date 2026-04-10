# 2.3 Containers

- Objective: Understand container-oriented Kubernetes behavior beyond "just run an image", including runtime abstractions and pod-level execution details.
- Outcomes: Explain image handling, container environment construction, runtime classes, lifecycle hooks, and CRI interactions.
- Notes: This module works best when learners see how container behavior is expressed in Pod specs and then observed live.

## Children

- 2.3.1 Images
- 2.3.2 Container Environment
- 2.3.3 Runtime Class
- 2.3.4 Container Lifecycle Hooks
- 2.3.5 Container Runtime Interface (CRI)

## Module wrap - quick validation

```bash
kubectl get nodes -o wide
kubectl get pods -A | head -n 25
kubectl get runtimeclass 2>/dev/null || true
```
