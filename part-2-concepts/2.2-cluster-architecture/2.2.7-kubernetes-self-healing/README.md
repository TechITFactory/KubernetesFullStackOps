# 2.2.7 Kubernetes Self-Healing — teaching transcript

## Intro

Self-healing = controllers + probes + scheduling, not magic.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** `self-healing-demo.sh` **applies** the YAML — no second apply needed.

## Lab — Quick Start

**What happens when you run this:**  
- Script applies **`self-healing-demo`** namespace + Deployment.  
- Lists deploy + pods with label in that namespace.

```bash
chmod +x scripts/*.sh
./scripts/self-healing-demo.sh
kubectl get deploy,pods -n self-healing-demo -l app=self-healing-demo
```

**Expected:**  
Replicas stay at desired count; deleting a pod recreates it.

## Video close — fast validation

**What happens when you run this:**  
Delete one pod (`--wait=false`); `kubectl get pods -w` until replacement shows (Ctrl+C to stop watch).

```bash
kubectl get deploy,pods -n self-healing-demo -l app=self-healing-demo -o wide
kubectl delete pod -n self-healing-demo -l app=self-healing-demo --wait=false
kubectl get pods -n self-healing-demo -l app=self-healing-demo -w
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/self-healing-demo.sh` | Apply + get |
| `yamls/self-healing-demo.yaml` | Demo |
| `yamls/failure-troubleshooting.yaml` | Probes / rollout |

## Cleanup

```bash
kubectl delete namespace self-healing-demo --ignore-not-found
```

## Next

[2.2.8 Garbage collection](../2.2.8-garbage-collection/README.md)
