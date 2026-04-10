# 3.7.6 Expose Pod Information to Containers Through Files

- Summary: Expose pod metadata inside containers using Downward API files.
- Content:
  - Downward API passes pod metadata without app code changes.
  - File projection is useful for runtime metadata inspection.
  - Validate mounted file contents from container.
- Lab:

```bash
cat <<'EOF' > downward-file.yaml
apiVersion: v1
kind: Pod
metadata:
  name: downward-file
  labels:
    app: meta-demo
spec:
  containers:
    - name: app
      image: busybox:1.36
      command: ["/bin/sh","-c"]
      args: ["cat /etc/podinfo/labels; sleep 3600"]
      volumeMounts:
        - name: podinfo
          mountPath: /etc/podinfo
  volumes:
    - name: podinfo
      downwardAPI:
        items:
          - path: "labels"
            fieldRef:
              fieldPath: metadata.labels
EOF
kubectl apply -f downward-file.yaml
kubectl logs downward-file
```

Success signal: pod label data visible in mounted file output.
Failure signal: file missing due to incorrect field path.

EKS extension: same pattern works for sidecar metadata-aware logging.
