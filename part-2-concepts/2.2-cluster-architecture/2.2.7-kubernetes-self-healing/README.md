# 2.2.7 Kubernetes Self-Healing

- Summary: Kubernetes self-healing is not magic; it is a combination of probes, controllers, scheduling, and reconciliation.
- Content: Focus on restarts, rescheduling, replica restoration, and how readiness/liveness tie into availability.
- Lab: Delete a pod from a Deployment and watch the controller restore it.

## Assets

- `scripts/self-healing-demo.sh`
- `yamls/self-healing-demo.yaml`
