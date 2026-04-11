# 2.4.1.5 Disruptions â€” teaching transcript

## Intro

**Disruptions** are anything that terminates or evicts Pods. **Voluntary** disruptions are **planned**: cluster upgrades, **`kubectl drain`**, rolling updates, human scale-down. **Involuntary** disruptions are **unplanned**: **node crash**, **kernel panic**, **OOM kill**, zone outage. **PodDisruptionBudget** (PDB) limits how many **voluntary** evictions may happen at once via **`minAvailable`** or **`maxUnavailable`** on a **label-selected** set of Pods. It does **not** stop involuntary failures. Always run **`kubectl drain`** with **`--dry-run=server`** (or client) **first** to see what would happen; if **ALLOWED DISRUPTIONS** is **0** on the PDB, drain **blocks** or waits because the eviction API respects the budget.

**Prerequisites:** [2.4.1.4 Ephemeral Containers](../05-ephemeral-containers/README.md) recommended.

## Flow of this lesson

```
  Voluntary: drain / rollout / delete
            â”‚
            â”œâ”€â–º PDB allows? â”€â”€yesâ”€â”€â–º pods evicted/replaced
            â”‚        â”‚
            â”‚        no (ALLOWED DISRUPTIONS 0)
            â”‚              â””â”€â”€â–º drain blocks / eviction denied

  Involuntary: node loss / OOM
            â”‚
            â””â”€â”€â–º PDB does not prevent loss; controllers recreate pods
```

**Say:**

PDB is a **safety rail for maintenance**, not HA against fire.

## Learning objective

- Contrast **voluntary** and **involuntary** disruptions.
- Read **PodDisruptionBudget** status including **allowed disruptions**.
- Use **`kubectl drain --dry-run`** before real drain operations.

## Why this matters

A PDB set too strictly freezes node upgrades; one set too loosely takes out an entire stateful quorum during maintenance.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.4-workloads/01-pods/06-disruptions" 2>/dev/null || cd .
```

## Step 1 â€” Apply PDB demo and describe

**What happens when you run this:**

The PDB is admitted; **status** may show **0** allowed until matching Pods exist.

**Say:**

I explain **`minAvailable: 1`** means â€œnever voluntarily go to zero healthy pods matching this selector.â€

**Run:**

```bash
kubectl apply -f yamls/disruption-notes.yaml
kubectl get poddisruptionbudget.policy disruption-demo
kubectl describe poddisruptionbudget disruption-demo
```

**Expected:** PDB is admitted; status reflects current matching pods (may show `0` until you create pods with `app: disruption-demo`).

---

## Step 2 â€” Dry-run drain on a node (read-only rehearsal)

**What happens when you run this:**

**`--dry-run=server`** asks the API server to validate eviction without doing itâ€”shows PDB conflicts early.

**Say:**

I pick **`NODE`** from `kubectl get nodes`; on single-node labs drain may still teach the **message** when PDB blocks.

**Run:**

```bash
NODE="$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')"
kubectl drain "$NODE" --dry-run=server --ignore-daemonsets 2>&1 | head -n 40 || true
```

**Expected:** Output lists what would be evicted or errors if PDB / unsafe parameters; no actual drain.

## Video close â€” fast validation

```bash
kubectl get pdb
kubectl get pods -l app=disruption-demo 2>/dev/null || true
```

## Troubleshooting

- **Drain stuck with PDB** â†’ check **`kubectl describe pdb`** for **ALLOWED DISRUPTIONS 0**; relax budget temporarily or add replicas
- **PDB never matches pods** â†’ fix **selector** labels on Pods
- **Involuntary outage took quorum** â†’ PDB would not help; fix HA topology and storage
- **`Forbidden` on eviction** â†’ RBAC for **`pods/eviction`**
- **DaemonSet pods block drain** â†’ use **`--ignore-daemonsets`** consciously; know what stays on the node
- **Dry-run differs from real drain** â†’ race conditions still possible; re-check PDB before production drain

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/disruption-notes.yaml` | PDB demo manifest |
| `yamls/failure-troubleshooting.yaml` | Selector mismatch and eviction drills |

## Cleanup

```bash
kubectl delete -f yamls/disruption-notes.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.1.6 Pod Hostname](../07-pod-hostname/README.md)
