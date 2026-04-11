# 3.5.4 Imperative Management of Kubernetes Objects Using Configuration Files . 27

- Summary: Apply and update YAML resources with imperative `kubectl apply`.
- Content:
  - Imperative with files gives speed plus reproducible specs.
  - Use `diff` before apply to preview changes.
  - Validate rollout and object state after each apply.
- Lab:

```bash
kubectl create deployment file-demo --image=nginx:1.27 --dry-run=client -o yaml > file-demo.yaml
kubectl apply -f file-demo.yaml
kubectl get deploy file-demo
```

Update and reapply:

```bash
kubectl set image deployment/file-demo nginx=nginx:1.27.1 --local -o yaml > file-demo.yaml
kubectl diff -f file-demo.yaml || true
kubectl apply -f file-demo.yaml
kubectl rollout status deployment/file-demo
```

Success signal: changes applied and rollout completes.
Failure signal: apply succeeds but rollout hangs due to bad image/config.
