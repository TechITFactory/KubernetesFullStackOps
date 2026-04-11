# 3.5.1 Declarative Management of Kubernetes Objects Using Configuration Files 27

- Summary: Manage desired state with declarative YAML and `kubectl apply`.
- Content:
  - Declarative config is repeatable and GitOps-friendly.
  - Compare desired vs live state before applying changes.
  - Use rollout checks for safe updates.
- Lab:

```bash
cat <<'EOF' > declarative-demo.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: declarative-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: declarative-demo
  template:
    metadata:
      labels:
        app: declarative-demo
    spec:
      containers:
        - name: app
          image: nginx:1.27
EOF
kubectl apply -f declarative-demo.yaml
kubectl get deploy declarative-demo
kubectl rollout status deployment/declarative-demo
```

Success signal: live state converges to manifest spec.
Failure signal: drift persists or rollout fails.
