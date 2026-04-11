# 2.1.3 The Kubernetes API — teaching transcript

## Intro

The API server is the **source of truth**. This lesson uses **discovery** (`/api`, `/apis`) and `kubectl` helpers to see groups, resources, and versions.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** Script header in `scripts/explore-k8s-api.sh` matches the **What happens** bullets below.

**Say:**  
Nothing in the cluster “remembers” state except through the API; discovery tells me what verbs exist.

## Lab — Quick Start

**What happens when you run this:**  
- `explore-k8s-api.sh` — `api-versions`, `api-resources`, `kubectl get --raw /`.  
- `kubectl get --raw /api` and `/apis` — first 300 bytes of JSON (truncated) so your terminal does not flood.

```bash
chmod +x scripts/*.sh
./scripts/explore-k8s-api.sh
kubectl get --raw /api | head -c 300 && echo
kubectl get --raw /apis | head -c 300 && echo
```

**Expected:**  
JSON discovery payloads; script completes without auth errors.

## Video close — fast validation

**What happens when you run this:**  
Control-plane endpoint summary; samples of resource types and API versions — read-only.

```bash
kubectl cluster-info
kubectl api-resources | head -n 25
kubectl api-versions | head -n 20
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/explore-k8s-api.sh` | Discovery bundle |
| `yamls/api-discovery-notes.yaml` | Reference notes |
| `yamls/failure-troubleshooting.yaml` | Auth / discovery failures |

## Next

[2.1.4 The kubectl command-line tool](../2.1.4-the-kubectl-command-line-tool/README.md)
