# 3.6.1 Managing Secrets Using kubectl

- Summary: Create and use Kubernetes secrets directly with `kubectl`.
- Content:
  - Secret objects store sensitive values in base64 form.
  - Use `envFrom` or volume mounts to consume secrets.
  - Validate pod behavior without printing sensitive values.
- Lab:

```bash
kubectl create secret generic app-secret \
  --from-literal=DB_USER=appuser \
  --from-literal=DB_PASS='change-me'

cat <<'EOF' > secret-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
    - name: app
      image: busybox:1.36
      command: ["/bin/sh","-c"]
      args: ["[ -n \"$DB_USER\" ] && echo secret-loaded && sleep 3600"]
      envFrom:
        - secretRef:
            name: app-secret
EOF
kubectl apply -f secret-pod.yaml
kubectl logs secret-pod
```

Success signal: pod logs show `secret-loaded`.
Failure signal: pod starts but secret env vars are missing.

EKS extension: prefer IAM roles + external secret manager where possible.
