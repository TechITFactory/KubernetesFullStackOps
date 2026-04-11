# 3.13.4 Running Pods on Only Some Nodes

- Summary: Restrict workload placement to specific nodes using labels/selectors.
- Content:
  - Node targeting is useful for specialized hardware/workloads.
  - Use labels and selectors rather than node name hardcoding.
  - Validate placement and fail-safe behavior.
- Lab:

```bash
kubectl label node <node-name> workload-type=special
cat <<'EOF' > node-select-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-select-pod
spec:
  nodeSelector:
    workload-type: special
  containers:
    - name: app
      image: nginx:1.27
EOF
kubectl apply -f node-select-pod.yaml
kubectl get pod node-select-pod -o wide
```

Success signal: pod lands on labeled node.
Failure signal: pod pending due to selector mismatch.

EKS extension: combine with managed node groups and taints for stronger isolation.
