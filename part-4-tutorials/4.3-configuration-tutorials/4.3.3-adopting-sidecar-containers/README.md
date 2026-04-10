# 4.3.3 Adopting Sidecar Containers

- Summary: Use sidecar containers to add capability without changing main app image.
- Content:
  - Sidecars handle supporting concerns like log shipping and proxying.
  - Keep app container simple; move extra concerns to sidecars.
  - Verify both containers are healthy and sharing expected volumes.
- Lab:

## Lab Steps (Linux)

```bash
cat <<'EOF' > sidecar-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-demo
spec:
  containers:
    - name: app
      image: busybox:1.36
      command: ["/bin/sh","-c"]
      args: ["while true; do date >> /var/log/app.log; sleep 5; done"]
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log
    - name: sidecar
      image: busybox:1.36
      command: ["/bin/sh","-c"]
      args: ["tail -n+1 -F /var/log/app.log"]
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log
  volumes:
    - name: shared-logs
      emptyDir: {}
EOF

kubectl apply -f sidecar-demo.yaml
kubectl get pod sidecar-demo
kubectl logs sidecar-demo -c sidecar --tail=20
```

Success signal: sidecar logs show timestamps written by app container.
Failure signal: sidecar cannot read shared log file.

EKS extension: common pattern for logging and service-mesh data plane.
