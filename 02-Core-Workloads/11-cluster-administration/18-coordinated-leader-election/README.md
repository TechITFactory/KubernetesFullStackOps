# 2.11.18 Coordinated leader election — teaching transcript

## Intro

**High-availability** **control** **plane** **components** **and** **many** **operators** **use** **Kubernetes** **`Lease`** **objects** **for** **leader** **election** **so** **only** **one** **replica** **acts** **at** **a** **time**. **Holding** **a** **lease** **requires** **renewals**; **network** **partitions** **can** **cause** **brief** **split-brain** **windows** **depending** **on** **timing** **and** **client** **logic**. **Inspecting** **leases** **is** **a** **practical** **debug** **skill** **for** **scheduler**, **controller-manager**, **and** **operator** **issues**.

**Prerequisites:** [2.11.17 Installing addons](../17-installing-addons/README.md); [2.10.1 Kubernetes scheduler](../../10-scheduling-preemption-and-eviction/01-kubernetes-scheduler/README.md).

## Flow of this lesson

```
  Candidates watch Lease in API
              │
              ▼
  Winner acquires/renews Lease holderIdentity
              │
              ▼
  Losers stay passive until lease expires
```

**Say:**

**If** **two** **replicas** **both** **think** **they** **are** **leader**, **I** **open** **the** **`Lease`** **YAML** **and** **check** **`renewTime`**.

## Learning objective

- List **`Lease`** **objects** **and** **read** **`holderIdentity`** **and** **`renewTime`** **fields**.
- Relate **leases** **to** **scheduler** **and** **operator** **HA** **patterns**.

## Why this matters

**Stuck** **leases** **after** **node** **crashes** **delay** **failover** **until** **TTL** **logic** **runs**—**knowing** **that** **prevents** **panic** **during** **drills**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/18-coordinated-leader-election" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-18-coordinated-leader-election-notes.yaml
kubectl get cm -n kube-system 2-11-18-coordinated-leader-election-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-18-coordinated-leader-election-notes`** when allowed.

---

## Step 2 — Leases in kube-system (read-only)

**What happens when you run this:**

**Shows** **component** **and** **operator** **leases** **(names** **vary** **by** **cluster)**.

**Run:**

```bash
kubectl get lease -n kube-system 2>/dev/null | head -n 25 || true
L="$(kubectl get lease -n kube-system -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [ -n "$L" ]; then kubectl get lease "$L" -n kube-system -o yaml 2>/dev/null | head -n 35; fi || true
```

**Expected:** **Lease** **table**; **optional** **YAML** **head**.

## Video close — fast validation

```bash
kubectl explain lease.spec 2>/dev/null | head -n 25 || true
```

## Troubleshooting

- **No** **leases** **visible** → **RBAC** **or** **different** **namespace** **for** **operator**
- **Expired** **lease** **not** **reclaimed** → **clock** **skew**, **API** **outage**, **buggy** **client**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-18-coordinated-leader-election-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-11-18-coordinated-leader-election-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.12 Windows in Kubernetes](../../12-windows-in-kubernetes/README.md)
