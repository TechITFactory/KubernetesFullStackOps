# 2.2.7 Kubernetes Self-Healing

- Summary: Kubernetes self-healing is not magic; it is a combination of probes, controllers, scheduling, and reconciliation.
- Content: Focus on restarts, rescheduling, replica restoration, and how readiness/liveness tie into availability.
- Lab: Delete a pod from a Deployment and watch the controller restore it.

## Assets

- `scripts/self-healing-demo.sh`
- `yamls/self-healing-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/self-healing-demo.sh
kubectl apply -f yamls/self-healing-demo.yaml
kubectl get deploy,pods -l app=self-healing-demo
```

## Expected output

- Deployment stays at desired replica count.
- Deleting one pod results in a replacement pod automatically.

## Video close - fast validation

```bash
kubectl get deploy,pods -l app=self-healing-demo -o wide
kubectl delete pod -l app=self-healing-demo --wait=false
kubectl get pods -l app=self-healing-demo -w
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common probe, rollout, and controller recovery failures.
