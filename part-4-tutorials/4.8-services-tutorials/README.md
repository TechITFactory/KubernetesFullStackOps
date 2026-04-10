# 4.8 Services Tutorials

- Objective: Master service connectivity and traffic behavior in Kubernetes.
- Outcomes:
  - Connect workloads with Services and verify endpoint routing.
  - Understand source IP behavior and termination effects.
  - Debug traffic issues using service and endpoint state.
- Notes:
  - Labs are command-first and Linux-only.
  - Each lesson includes validation checks and failure signals.
  - EKS mapping included where needed.

## Children

- 4.8.1 Connecting Applications with Services
- 4.8.2 Using Source IP
- 4.8.3 Explore Termination Behavior for Pods And Their Endpoints

## Module Validation

```bash
kubectl get svc,endpoints -A
kubectl get pods -A
```
