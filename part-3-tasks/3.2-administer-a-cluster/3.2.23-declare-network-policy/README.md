# 3.2.23 Declare Network Policy

- Summary: Restrict pod-to-pod traffic using Kubernetes NetworkPolicy.
- Content:
  - Default behavior is often open east-west traffic.
  - Start with deny-all and then allow required flows.
  - Validate policy with connectivity tests from test pods.
- Lab:

```bash
kubectl create ns np-lab
kubectl run backend -n np-lab --image=nginx:1.27 --labels=app=backend
kubectl run client -n np-lab --image=busybox:1.36 --restart=Never -- sleep 3600
kubectl exec -n np-lab client -- wget -qO- http://backend
```

Apply deny-all ingress:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: np-lab
spec:
  podSelector: {}
  policyTypes:
    - Ingress
EOF
kubectl exec -n np-lab client -- wget -T 3 -qO- http://backend
```

Success signal: traffic blocked after deny policy.
Failure signal: traffic still allowed due to missing CNI policy support.

EKS extension: ensure CNI/network policy engine supports enforcement mode used.
