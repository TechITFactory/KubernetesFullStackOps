# 3.3.12 Configure a Pod to Use a Volume for Storage

- Summary: Mount a volume into a pod and verify data path behavior.
- Content:
  - Volumes provide storage independent of container image.
  - `emptyDir` works for pod-lifetime shared data.
  - Verify mounted paths from inside the container.
- Lab:

```bash
cat <<'EOF' > volume-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-demo
spec:
  containers:
    - name: app
      image: busybox:1.36
      command: ["/bin/sh","-c"]
      args: ["echo hello > /data/msg.txt; sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      emptyDir: {}
EOF
kubectl apply -f volume-demo.yaml
kubectl exec volume-demo -- cat /data/msg.txt
```

Success signal: file written/read from mounted volume.
Failure signal: missing mount path or permission errors.

EKS extension: replace `emptyDir` with PVC for persistent data.
