# 3.3.23 Configure a Pod to Use a ConfigMap

- Summary: Inject configuration into pods using ConfigMap env vars and files.
- Content:
  - ConfigMap separates deploy config from application image.
  - Use env vars for simple key-values, files for larger config.
  - Validate config from inside running pod.
- Lab:

```bash
kubectl create configmap app-settings --from-literal=MODE=prod --from-literal=LOG_LEVEL=info
cat <<'EOF' > cm-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: cm-pod
spec:
  containers:
    - name: app
      image: busybox:1.36
      command: ["/bin/sh","-c"]
      args: ["env | grep -E 'MODE|LOG_LEVEL'; sleep 3600"]
      envFrom:
        - configMapRef:
            name: app-settings
EOF
kubectl apply -f cm-pod.yaml
kubectl logs cm-pod
```

Success signal: pod logs show MODE and LOG_LEVEL values.
Failure signal: pod starts but env vars missing due to reference mismatch.

EKS extension: same config pattern; add GitOps flow for environment config changes.
