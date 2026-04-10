# 3.3.13 Configure a Pod to Use a PersistentVolume for Storage

- Summary: Bind PVC to PV and mount persistent storage in a pod.
- Content:
  - Persistent volumes survive pod restart and reschedule.
  - PVC abstracts storage requests from concrete backend.
  - Validate binding and mounted data path.
- Lab:

```bash
cat <<'EOF' > pvc-demo.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-demo
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 1Gi
EOF
kubectl apply -f pvc-demo.yaml
kubectl get pvc pvc-demo
```

Mount in pod:

```bash
cat <<'EOF' > pvc-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
spec:
  containers:
    - name: app
      image: busybox:1.36
      command: ["sh","-c","echo data > /mnt/data/file.txt; sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /mnt/data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: pvc-demo
EOF
kubectl apply -f pvc-pod.yaml
kubectl exec pvc-pod -- cat /mnt/data/file.txt
```

Success signal: PVC bound and file readable from mounted path.
Failure signal: PVC pending due to storage class/provisioning issue.

EKS extension: use EBS CSI driver and StorageClass policies.
