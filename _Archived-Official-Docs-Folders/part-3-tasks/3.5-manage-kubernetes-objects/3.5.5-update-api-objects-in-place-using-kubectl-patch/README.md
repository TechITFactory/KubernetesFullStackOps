# 3.5.5 Update API Objects in Place Using kubectl patch

- Summary: Update live resources safely using `kubectl patch`.
- Content:
  - Patch is fast for targeted production-safe updates.
  - Use strategic/merge/json patch depending on object shape.
  - Validate resource generation and rollout after patch.
- Lab:

```bash
kubectl create deployment patch-demo --image=nginx:1.27
kubectl patch deployment patch-demo -p '{"spec":{"replicas":3}}'
kubectl patch deployment patch-demo -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","image":"nginx:1.27.1"}]}}}}'
kubectl get deployment patch-demo
kubectl rollout status deployment/patch-demo
```

Success signal: deployment updates applied and rollout completes.
Failure signal: patch accepted but rollout stalls due to bad image/config.
