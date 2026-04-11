# 2.1.4 The kubectl Command-Line Tool — teaching transcript

## Intro

`kubectl` is your **inspection and reconciliation** tool: contexts, namespaces, output shapes, and declarative apply.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** **WHAT THIS DOES WHEN YOU RUN IT** — `scripts/kubectl-essentials.sh`.

**Say:**  
I always know *which cluster* (`current-context`) before I change anything.

## Lab — Quick Start

**What happens when you run this:**  
- `kubectl-essentials.sh` — prints context, namespaces, sample `api-resources`, custom-columns node view.  
- `kubectl apply kubectl-practice-namespace.yaml` — creates the practice namespace.  
- `kubectl get ns kubectl-practice` — confirms it exists.

```bash
chmod +x scripts/*.sh
./scripts/kubectl-essentials.sh
kubectl apply -f yamls/kubectl-practice-namespace.yaml
kubectl get ns kubectl-practice
```

**Expected:**  
No client/auth errors; namespace `kubectl-practice` listed.

## Video close — fast validation

**What happens when you run this:**  
Context name; nodes; grep for practice namespace — read-only.

```bash
kubectl config current-context
kubectl get nodes
kubectl get ns | grep kubectl-practice || true
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/kubectl-essentials.sh` | Context + formatting demo |
| `yamls/kubectl-practice-namespace.yaml` | Practice namespace |
| `yamls/failure-troubleshooting.yaml` | Context / RBAC / output issues |

## Next

[2.2 Cluster architecture](../../2.2-cluster-architecture/README.md)
