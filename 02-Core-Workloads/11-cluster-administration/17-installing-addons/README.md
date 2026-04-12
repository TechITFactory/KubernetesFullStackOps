# Installing addons — teaching transcript

## Intro

**Addons** **are** **cluster** **extensions** **delivered** **as** **Deployments**, **DaemonSets**, **CRDs**, **and** **webhooks**: **DNS**, **CNI** **plugins**, **metrics-server**, **ingress** **controllers**, **CSI** **drivers**, **and** **policy** **engines**. **Good** **installation** **practices** **pin** **versions**, **use** **GitOps**, **verify** **signatures**, **and** **isolate** **RBAC** **per** **addon** **namespace**. **This** **lesson** **uses** **read-only** **inspection** **of** **what** **is** **already** **present**.

**Prerequisites:** [2.11.16 API Priority and Fairness](../16-api-priority-and-fairness/README.md).

## Flow of this lesson

```
  Choose addon + version + compatibility matrix
              │
              ▼
  Apply manifests or Helm with values pinned
              │
              ▼
  Verify pods, webhooks, and CRDs; monitor upgrades
```

**Say:**

**I** **never** **demo** **`kubectl apply -f` from random URLs** **without** **showing** **hash** **verification** **first**—**supply** **chain** **matters**.

## Learning objective

- Inventory **kube-system** **and** **common** **addon** **namespaces** **with** **repo** **script**.
- List **CRD** **count** **as** **a** **rough** **complexity** **signal**.

## Why this matters

**Sprawling** **addons** **become** **the** **real** **control** **plane** **surface** **area** **for** **attacks** **and** **upgrades**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/17-installing-addons" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-17-installing-addons-notes.yaml
kubectl get cm -n kube-system 2-11-17-installing-addons-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-17-installing-addons-notes`** when allowed.

---

## Step 2 — kube-system footprint and CRDs (read-only)

**What happens when you run this:**

**Script** **lists** **kube-system** **pods**; **CRD** **count** **shows** **extension** **surface**.

**Run:**

```bash
bash scripts/inspect-2-11-17-installing-addons.sh 2>/dev/null | head -n 25 || true
kubectl get crd --no-headers 2>/dev/null | wc -l 2>/dev/null || true
```

**Expected:** **Pod** **list**; **integer** **CRD** **count** **(may** **fail** **on** **Windows** **`wc`).

## Video close — fast validation

```bash
kubectl get ns 2>/dev/null | grep -iE 'ingress|monitor|cert|istio|linkerd' | head -n 10 || true
```

## Troubleshooting

- **Addon** **mutating** **webhook** **breaks** **upgrades** → **test** **in** **staging** **with** **dry-run**
- **`wc` on Windows** → **Git** **Bash** **or** **WSL**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-17-installing-addons-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-11-17-installing-addons.sh` | **`kubectl get pods -n kube-system`** |

## Cleanup

```bash
kubectl delete configmap 2-11-17-installing-addons-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.18 Coordinated leader election](../18-coordinated-leader-election/README.md)
