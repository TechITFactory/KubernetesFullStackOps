# 2.2.3 Controllers — teaching transcript

## Intro

Controllers **reconcile** loop: desired replicas → real Pods.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** `controller-reconciliation-demo.sh` **already applies** the manifest — do **not** duplicate `kubectl apply` unless you intend a second pass.

## Lab — Quick Start

**What happens when you run this:**  
- Script applies Namespace + Deployment into **`controller-demo`**.  
- Shows deploy + pods in that namespace.  
- Optional: delete one pod and watch it come back (`kubectl delete pod -n controller-demo -l app=controller-demo`).

```bash
chmod +x scripts/*.sh
./scripts/controller-reconciliation-demo.sh
kubectl get deploy,pods -n controller-demo -l app=controller-demo
```

**Expected:**  
Two replicas `Running`; after manual pod delete, count returns to two.

## Video close — fast validation

**What happens when you run this:**  
State check; describe deploy; recent events.

```bash
kubectl get deploy,pods -n controller-demo -l app=controller-demo
kubectl describe deploy controller-demo -n controller-demo | sed -n '1,80p'
kubectl get events -n controller-demo --sort-by=.lastTimestamp | tail -n 20
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/controller-reconciliation-demo.sh` | Apply + hint |
| `yamls/controller-demo-deployment.yaml` | Demo manifest |
| `yamls/failure-troubleshooting.yaml` | Rollout / selector |

## Cleanup

```bash
kubectl delete namespace controller-demo --ignore-not-found
```

## Next

[2.2.4 Leases](../2.2.4-leases/README.md)
