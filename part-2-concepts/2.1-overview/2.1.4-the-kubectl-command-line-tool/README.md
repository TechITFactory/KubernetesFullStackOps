# 2.1.4 The kubectl Command-Line Tool

- Summary: `kubectl` is the primary operational interface for Kubernetes and should be taught as an inspection and reconciliation tool, not just a command list.
- Content: This section covers context management, imperative vs declarative workflows, output shaping, and safe day-to-day inspection commands.
- Lab: Switch contexts, inspect objects with custom output, and apply a manifest declaratively.

## Assets

- `scripts/kubectl-essentials.sh`
- `yamls/kubectl-practice-namespace.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/kubectl-essentials.sh
kubectl apply -f yamls/kubectl-practice-namespace.yaml
kubectl get ns kubectl-practice
```

## Expected output

- `kubectl` context and output formatting commands run without client/auth errors.
- Practice namespace is created and visible with `kubectl get ns`.

## Video close - fast validation

```bash
kubectl config current-context
kubectl get nodes
kubectl get ns | grep kubectl-practice || true
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common context, RBAC, and command/output troubleshooting steps.
