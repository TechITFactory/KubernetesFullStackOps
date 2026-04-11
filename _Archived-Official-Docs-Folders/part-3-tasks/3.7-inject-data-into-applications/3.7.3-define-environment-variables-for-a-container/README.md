# 3.7.3 Define Environment Variables for a Container

- Summary: Configure container environment variables directly in pod specs.
- Content:
  - Env vars are simple for runtime toggles and app config.
  - Keep non-sensitive values in manifests; secrets elsewhere.
  - Validate env vars from running container output.
- Lab:

```bash
cat <<'EOF' > env-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-demo
spec:
  containers:
    - name: app
      image: busybox:1.36
      command: ["/bin/sh","-c"]
      args: ["env | grep -E 'APP_MODE|APP_REGION'; sleep 3600"]
      env:
        - name: APP_MODE
          value: production
        - name: APP_REGION
          value: us-east-1
EOF
kubectl apply -f env-demo.yaml
kubectl logs env-demo
```

Success signal: expected env vars shown in logs.
Failure signal: missing env keys due to manifest typo.

EKS extension: same env patterns, but externalize sensitive values to secrets manager flow.
