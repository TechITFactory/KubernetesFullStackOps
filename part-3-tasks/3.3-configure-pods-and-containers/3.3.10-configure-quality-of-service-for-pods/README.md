# 3.3.10 Configure Quality of Service for Pods

- Summary: Control pod QoS class through request/limit configuration.
- Content:
  - QoS classes: Guaranteed, Burstable, BestEffort.
  - QoS influences eviction priority under pressure.
  - Validate class assignment from pod status.
- Lab:

```bash
cat <<'EOF' > qos-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: qos-demo
spec:
  containers:
    - name: app
      image: nginx:1.27
      resources:
        requests:
          cpu: "200m"
          memory: "128Mi"
        limits:
          cpu: "200m"
          memory: "128Mi"
EOF
kubectl apply -f qos-demo.yaml
kubectl get pod qos-demo -o jsonpath='{.status.qosClass}'; echo
kubectl describe pod qos-demo | grep -i "QoS Class"
```

Success signal: QoS class shown as expected (e.g., `Guaranteed`).
Failure signal: unexpected class due to mismatched requests/limits.

EKS extension: use QoS consistently for critical workloads under scale pressure.
