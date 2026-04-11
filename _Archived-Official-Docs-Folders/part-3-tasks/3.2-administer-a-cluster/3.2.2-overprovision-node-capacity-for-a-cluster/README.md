# 3.2.2 Overprovision Node Capacity For A Cluster

- Summary: Add overprovisioning pods to improve scheduling responsiveness.
- Content:
  - Low-priority placeholder pods reserve spare capacity.
  - Real workloads preempt placeholders during spikes.
  - Validate preemption and node scheduling behavior.
- Lab:

```bash
cat <<'EOF' > overprovision.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: overprovisioning
value: -1
globalDefault: false
description: "Low-priority overprovisioning"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: overprovision
spec:
  replicas: 2
  selector:
    matchLabels:
      app: overprovision
  template:
    metadata:
      labels:
        app: overprovision
    spec:
      priorityClassName: overprovisioning
      containers:
        - name: pause
          image: registry.k8s.io/pause:3.10
          resources:
            requests:
              cpu: "250m"
              memory: "256Mi"
EOF
kubectl apply -f overprovision.yaml
kubectl get pods -l app=overprovision -o wide
```

Success signal: placeholder pods running; schedulable capacity behavior improved.
Failure signal: placeholders block critical workloads due to wrong priority setup.
