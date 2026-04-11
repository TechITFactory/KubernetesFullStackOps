# 3.7 Inject Data Into Applications

- Objective: Inject runtime data into workloads safely and predictably.
- Outcomes:
  - Configure commands, env vars, metadata injection, and secrets usage.
  - Choose between env vars and file projections for data delivery.
  - Validate injected data in running containers.
- Notes:
  - Keep sensitive data in secrets, not plain manifests.
  - Verify values from pod logs/exec after apply.
  - Linux practical flows with minimal theory.

## Children

- 3.7.1 Define a Command and Arguments for a Container
- 3.7.2 Define Dependent Environment Variables
- 3.7.3 Define Environment Variables for a Container
- 3.7.4 Define Environment Variable Values Using An Init Container
- 3.7.5 Expose Pod Information to Containers Through Environment Variables
- 3.7.6 Expose Pod Information to Containers Through Files
- 3.7.7 Distribute Credentials Securely Using Secrets

## Module Validation

```bash
kubectl get configmap,secret -A
kubectl logs <pod-name> -n <namespace>
kubectl exec -it <pod-name> -n <namespace> -- env
```
