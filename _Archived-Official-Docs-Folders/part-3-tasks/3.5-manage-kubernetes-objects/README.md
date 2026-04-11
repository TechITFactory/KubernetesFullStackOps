# 3.5 Manage Kubernetes Objects

- Objective: Manage Kubernetes resources safely using declarative and imperative workflows.
- Outcomes:
  - Apply and update manifests using file-based workflows.
  - Use imperative commands for fast operational fixes.
  - Understand patch and migration patterns for API objects.
- Notes:
  - Prefer declarative source of truth for repeatability.
  - Use imperative for controlled urgent operations.
  - Validate object state after every change.

## Children

- 3.5.1 Declarative Management of Kubernetes Objects Using Configuration Files 27
- 3.5.2 Declarative Management of Kubernetes Objects Using Kustomize
- 3.5.3 Managing Kubernetes Objects Using Imperative Commands
- 3.5.4 Imperative Management of Kubernetes Objects Using Configuration Files . 27
- 3.5.5 Update API Objects in Place Using kubectl patch
- 3.5.6 Migrate Kubernetes Objects Using Storage Version Migration

## Module Validation

```bash
kubectl get all -A
kubectl api-resources
kubectl get events -A --sort-by=.lastTimestamp | tail -n 25
```
