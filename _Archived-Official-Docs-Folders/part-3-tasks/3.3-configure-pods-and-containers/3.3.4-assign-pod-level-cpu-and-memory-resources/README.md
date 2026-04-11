# 3.3.4 Assign Pod-level CPU and Memory Resources

- Summary: Set aggregate resource controls at pod workload level.
- Content:
  - Pod-level planning prevents resource overcommit per workload.
  - Combine container requests/limits for total pod behavior.
  - Verify scheduler placement and runtime stability.
- Lab:

```bash
cat <<'EOF' > pod-resources.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-resources
spec:
  containers:
    - name: app1
      image: nginx:1.27
      resources:
        requests: {cpu: "100m", memory: "64Mi"}
        limits: {cpu: "200m", memory: "128Mi"}
    - name: app2
      image: busybox:1.36
      command: ["sh","-c","sleep 3600"]
      resources:
        requests: {cpu: "100m", memory: "64Mi"}
        limits: {cpu: "200m", memory: "128Mi"}
EOF
kubectl apply -f pod-resources.yaml
kubectl describe pod pod-resources
```

Success signal: pod scheduled and both containers healthy.
Failure signal: insufficient node resources for combined requests.

EKS extension: align pod requests with node group sizing strategy.
