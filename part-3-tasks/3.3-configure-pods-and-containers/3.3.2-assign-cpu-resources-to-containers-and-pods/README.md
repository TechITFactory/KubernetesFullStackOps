# 3.3.2 Assign CPU Resources to Containers and Pods

- Summary: Set CPU requests/limits and verify scheduler/runtime behavior.
- Content:
  - Requests affect scheduling; limits cap usage.
  - Missing limits can cause noisy-neighbor issues.
  - Validate effective resources from pod description.
- Lab:

```bash
cat <<'EOF' > cpu-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: cpu-demo
spec:
  containers:
    - name: app
      image: nginx:1.27
      resources:
        requests:
          cpu: "250m"
        limits:
          cpu: "500m"
EOF
kubectl apply -f cpu-demo.yaml
kubectl get pod cpu-demo
kubectl describe pod cpu-demo | grep -A6 -i requests
```

Success signal: pod schedules and shows configured request/limit.
Failure signal: pod pending due to insufficient CPU.

EKS extension: combine with cluster autoscaler and requests-based capacity planning.
