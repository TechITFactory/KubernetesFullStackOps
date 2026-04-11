# 3.10.9 Communicate Between Containers in the Same Pod Using a Shared Volume

- Summary: Share data between sidecar containers via a common volume.
- Content:
  - Containers in same pod can communicate through shared filesystem.
  - `emptyDir` is ideal for ephemeral intra-pod data exchange.
  - Validate write/read flow across containers.
- Lab:

```bash
cat <<'EOF' > shared-volume-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-volume-pod
spec:
  containers:
    - name: writer
      image: busybox:1.36
      command: ["/bin/sh","-c"]
      args: ["while true; do date > /shared/data.txt; sleep 5; done"]
      volumeMounts:
        - name: shared
          mountPath: /shared
    - name: reader
      image: busybox:1.36
      command: ["/bin/sh","-c"]
      args: ["while true; do cat /shared/data.txt; sleep 5; done"]
      volumeMounts:
        - name: shared
          mountPath: /shared
  volumes:
    - name: shared
      emptyDir: {}
EOF
kubectl apply -f shared-volume-pod.yaml
kubectl logs shared-volume-pod -c reader --tail=20
```

Success signal: reader logs show timestamps written by writer.
Failure signal: reader cannot find shared file path.

EKS extension: same approach used for sidecar log processors and proxy coordination.
