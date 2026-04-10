# 3.5.3 Managing Kubernetes Objects Using Imperative Commands

- Summary: Manage resources quickly with imperative `kubectl` commands.
- Content:
  - Imperative commands are useful for fast ops and debugging.
  - Use `--dry-run=client -o yaml` to bridge to declarative workflows.
  - Validate object state after each command.
- Lab:

```bash
kubectl create deployment imp-demo --image=nginx:1.27
kubectl expose deployment imp-demo --port=80 --type=ClusterIP
kubectl scale deployment imp-demo --replicas=3
kubectl set image deployment/imp-demo nginx=nginx:1.27.1
kubectl get deploy,pod,svc imp-demo
```

Success signal: deployment updated and pods healthy at target replicas.
Failure signal: rollout stalls after image update.

EKS extension: same commands used for urgent incident actions.
