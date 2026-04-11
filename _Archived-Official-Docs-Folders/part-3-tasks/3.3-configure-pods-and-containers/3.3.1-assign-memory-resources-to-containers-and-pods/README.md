# 3.3.1 Assign Memory Resources to Containers and Pods

- Summary: Configure memory requests and limits for predictable scheduling.
- Content:
  - Requests decide scheduling, limits bound runtime memory.
  - Wrong memory settings cause OOMKills or pending pods.
  - Validate effective values in pod description/events.
- Lab:

```bash
cat <<'EOF' > mem-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: mem-demo
spec:
  containers:
    - name: app
      image: nginx:1.27
      resources:
        requests:
          memory: "128Mi"
        limits:
          memory: "256Mi"
EOF
kubectl apply -f mem-demo.yaml
kubectl describe pod mem-demo | grep -A8 -i Limits
```

Success signal: pod running with expected memory request/limit.
Failure signal: pod pending or OOMKilled.

EKS extension: right-size requests for autoscaler and cost efficiency.
