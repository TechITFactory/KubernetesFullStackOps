# 3.6.2 Managing Secrets Using Configuration File

- Summary: Manage secrets declaratively through YAML manifests.
- Content:
  - Declarative secrets fit GitOps workflows.
  - Use `stringData` for authoring convenience.
  - Validate references and avoid committing real credentials.
- Lab:

```bash
cat <<'EOF' > app-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: api-secret
type: Opaque
stringData:
  API_KEY: replace-in-real-env
  API_URL: https://example.local
EOF
kubectl apply -f app-secret.yaml
kubectl get secret api-secret
kubectl get secret api-secret -o yaml
```

Success signal: secret is created and consumable by workloads.
Failure signal: key names mismatch expected env var references.

EKS extension: encrypt secret data at rest using KMS-backed configuration.
