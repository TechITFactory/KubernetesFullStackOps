# 2.1.2.6 Field Selectors — teaching transcript

## Intro

Filter objects by **API fields** (e.g. Pod phase) when labels are not enough.

**Prerequisites:** [Part 1](../../../../part-1-getting-started/README.md).

**Teaching tip:** `field-selector-demo.sh` — header in script file.

## Lab — Quick Start

**What happens when you run this:**  
- Lists **Running** pods cluster-wide (can be long).  
- Lists **Warning** events cluster-wide (may be empty).

```bash
chmod +x scripts/*.sh
./scripts/field-selector-demo.sh
```

**Expected:**  
Two lists print; no kubectl errors.

## Video close — fast validation

**What happens when you run this:**  
Head-truncated Running vs non-Running pod samples — read-only.

```bash
kubectl get pods -A --field-selector=status.phase=Running 2>/dev/null | head -n 15
kubectl get pods -A --field-selector=status.phase!=Running 2>/dev/null | head -n 15
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/field-selector-demo.sh` | Running pods + Warning events |
| `yamls/failure-troubleshooting.yaml` | Unsupported fields / empty results |

## Next

[2.1.2.7 Finalizers](../2.1.2.7-finalizers/README.md)
