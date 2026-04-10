# 4.3 Configuration Tutorials

- Objective: Manage runtime configuration without rebuilding container images.
- Outcomes:
  - Use ConfigMaps to inject/update app settings.
  - Validate config changes safely in running workloads.
  - Apply sidecar pattern where appropriate.
- Notes:
  - Practical-first: every concept must map to a command and verification.
  - Linux-only command track.
  - Include EKS extension notes in each child lesson.

## Children

- 4.3.1 Updating Configuration via a ConfigMap
- 4.3.2 Configuring Redis Using a ConfigMap
- 4.3.3 Adopting Sidecar Containers

## Module Quick Validation

```bash
kubectl get configmaps -A
kubectl get deploy,pod -A
```
