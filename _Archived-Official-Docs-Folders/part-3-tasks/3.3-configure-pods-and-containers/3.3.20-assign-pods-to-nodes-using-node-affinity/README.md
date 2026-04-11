# 3.3.20 Assign Pods to Nodes Using Node Affinity

- Summary: Control pod placement using required and preferred node affinity.
- Content:
  - Affinity is safer and clearer than hardcoding node names.
  - `requiredDuringScheduling...` enforces strict placement.
  - Always verify node labels and pod placement.
- Lab:

```bash
kubectl label node <node-name> workload=apps
cat <<'EOF' > affinity-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity-demo
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: workload
                operator: In
                values: ["apps"]
  containers:
    - name: app
      image: nginx:1.27
EOF
kubectl apply -f affinity-demo.yaml
kubectl get pod affinity-demo -o wide
```

Success signal: pod scheduled onto labeled node.
Failure signal: pod stays pending with affinity mismatch.

EKS extension: combine node affinity with node groups and taints for workload isolation.
