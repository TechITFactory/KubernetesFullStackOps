# 4.8.2 Using Source IP

- Summary: Understand source IP preservation behavior for service traffic.
- Content:
  - Source IP can change based on service type and traffic path.
  - `externalTrafficPolicy: Local` preserves source IP for NodePort/LB.
  - Validate behavior before applying IP-based security logic.
- Lab:

```bash
kubectl create deployment srcip-demo --image=nginx:1.27
kubectl expose deployment srcip-demo --type=NodePort --port=80
kubectl get svc srcip-demo -o yaml | grep -i externalTrafficPolicy
kubectl patch svc srcip-demo -p '{"spec":{"externalTrafficPolicy":"Local"}}'
kubectl get svc srcip-demo -o yaml | grep -i externalTrafficPolicy
```

Success signal: service shows `externalTrafficPolicy: Local`.
Failure signal: policy patch fails due to unsupported service type/config.

EKS extension: validate source IP behavior with NLB and security groups.
