# 3.3.21 Configure Pod Initialization

- Summary: Use init containers to run setup tasks before app containers start.
- Content:
  - Init containers run to completion before app containers.
  - Useful for dependency checks, config generation, and migrations.
  - Validate init status and logs when startup fails.
- Lab:

```bash
cat <<'EOF' > init-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  initContainers:
    - name: init-check
      image: busybox:1.36
      command: ["sh","-c","echo init-ok > /work/status.txt"]
      volumeMounts:
        - name: work
          mountPath: /work
  containers:
    - name: app
      image: busybox:1.36
      command: ["sh","-c","cat /work/status.txt; sleep 3600"]
      volumeMounts:
        - name: work
          mountPath: /work
  volumes:
    - name: work
      emptyDir: {}
EOF
kubectl apply -f init-demo.yaml
kubectl get pod init-demo
kubectl logs init-demo -c app
```

Success signal: pod runs and app reads init-generated file.
Failure signal: pod stuck in `Init:*` state with init errors.
