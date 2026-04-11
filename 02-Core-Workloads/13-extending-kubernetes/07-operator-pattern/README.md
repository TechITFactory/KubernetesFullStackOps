# 2.13.3 Operator pattern — teaching transcript

## Intro

**Operators** **combine** **CRDs**, **controllers**, **and** **often** **admission** **webhooks** **to** **encode** **domain** **expertise** **(databases**, **queues**, **ingress**, **observability)** **in** **software**. **They** **reconcile** **desired** **state** **in** **custom** **resources** **toward** **actual** **state** **(Pods**, **Services**, **PVCs)** **continuously**. **Mature** **operators** **ship** **upgrade** **graphs**, **backup** **hooks**, **and** **RBAC** **scoped** **to** **their** **namespace**.

**Prerequisites:** [2.13.2.2 Kubernetes API aggregation layer](../06-kubernetes-api-aggregation-layer/README.md); [2.4 Workloads](../../04-workloads/README.md) **(controllers** **and** **reconciliation)**.

## Flow of this lesson

```
  Custom resource instance (CR) created
              │
              ▼
  Operator controller watches CR kind
              │
              ▼
  Creates/updates child resources; updates CR status
```

**Say:**

**Helm** **installs** **a** **snapshot**; **operators** **keep** **reconciling**—**that** **difference** **is** **the** **pitch**.

## Learning objective

- Use **repo** **inspect** **script** **to** **find** **operator-related** **API** **resources**.
- Describe **the** **reconcile** **loop** **in** **plain** **language**.

## Why this matters

**Blind** **`kubectl apply` of** **operator** **CRs** **without** **reading** **upgrade** **notes** **is** **how** **clusters** **lose** **data**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/13-extending-kubernetes/07-operator-pattern" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-13-3-operator-pattern-notes.yaml
kubectl get cm -n kube-system 2-13-3-operator-pattern-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-13-3-operator-pattern-notes`** when allowed.

---

## Step 2 — Operator-related API surface (read-only)

**What happens when you run this:**

**Script** **greps** **`api-resources`** **for** **`operator`**.

**Run:**

```bash
bash scripts/inspect-2-13-3-operator-pattern.sh 2>/dev/null || true
kubectl get pods -A 2>/dev/null | grep -i operator | head -n 15 || true
```

**Expected:** **API** **resource** **lines**; **optional** **operator** **pod** **names**.

## Video close — fast validation

```bash
kubectl get deploy -A 2>/dev/null | grep -i operator | head -n 12 || true
```

## Troubleshooting

- **Many** **false** **positives** **in** **grep** → **narrow** **by** **your** **vendor** **name**
- **Operator** **CrashLoop** → **webhook** **TLS**, **CRD** **version**, **RBAC**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-13-3-operator-pattern-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-13-3-operator-pattern.sh` | **`kubectl api-resources | grep -i operator`** |

## Cleanup

```bash
kubectl delete configmap 2-13-3-operator-pattern-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[Part 2: Concepts — module list](../../README.md)
