# 3.1 Install Tools

- Objective: Set up reliable Kubernetes CLI tooling for daily operations.
- Outcomes:
  - Install and verify `kubectl` on Linux.
  - Validate client/server compatibility before running tasks.
  - Use a repeatable verification checklist after setup.
- Notes:
  - Linux-first practical commands.
  - Keep tool versions aligned with cluster support window.
  - Same validation approach applies to local clusters and EKS.

## Children

- 3.1.1 Install and Set Up kubectl on Linux
- 3.1.2 Install and Set Up kubectl on macOS
- 3.1.3 Install and Set Up kubectl on Windows

## Quick Validation

```bash
kubectl version --client
kubectl config get-contexts
kubectl get nodes
```
