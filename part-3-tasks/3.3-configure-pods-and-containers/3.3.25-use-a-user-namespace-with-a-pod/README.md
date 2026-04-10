# 3.3.25 Use a User Namespace With a Pod

- Summary: Run pods with user namespaces for stronger isolation boundaries.
- Content:
  - User namespaces map container users away from host root IDs.
  - Improves isolation for untrusted workloads.
  - Validate runtime support and pod security context.
- Lab:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: userns-demo
spec:
  hostUsers: false
  containers:
    - name: app
      image: busybox:1.36
      command: ["sh","-c","id; sleep 3600"]
```

Apply and verify:

```bash
kubectl apply -f userns-demo.yaml
kubectl logs userns-demo
kubectl describe pod userns-demo
```

Success signal: pod runs and shows user namespace behavior.
Failure signal: feature unsupported by cluster/runtime version.
