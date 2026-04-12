# Scheduling Framework — teaching transcript

## Intro

The **scheduling** **framework** **(Kubernetes** **1.19+)** **organizes** **scheduler** **logic** **into** **extension** **points**: **pre-filter**, **filter**, **pre-score**, **score**, **reserve**, **permit**, **bind**, **post-bind**, **and** **others**. **In-tree** **plugins** **implement** **node** **affinity**, **inter-pod** **affinity**, **volumes**, **taints**, **and** **priority** **preemption**. **Out-of-tree** **plugins** **ship** **as** **webhook** **or** **compiled** **scheduler** **binaries** **depending** **on** **version** **and** **distro**. **Operators** **tune** **plugin** **configs** **via** **`KubeSchedulerConfiguration`** **(not** **usually** **editable** **with** **`kubectl`** **on** **managed** **clusters)**.

**Prerequisites:** [2.10.6 Taints and Tolerations](../06-taints-and-tolerations/README.md).

## Flow of this lesson

```
  Scheduler binary loads KubeSchedulerConfiguration
              │
              ▼
  Plugins registered at extension points
              │
              ▼
  Filter/score/bind pipeline executes per Pod
```

**Say:**

**When** **someone** **asks** **for** **a** **“custom** **predicate”**, **translate** **that** **to** **a** **filter** **plugin** **at** **the** **framework** **layer**.

## Learning objective

- Name **several** **scheduling** **framework** **extension** **points** **and** **their** **ordering** **in** **plain** **language**.
- Relate **`FailedScheduling`** **messages** **to** **plugin** **failures** **without** **needing** **cluster** **config** **access**.

## Why this matters

**Vendor** **Kubernetes** **often** **adds** **plugins** **for** **local** **storage**, **GPU** **fragmentation**, **or** **compliance**—**framework** **vocabulary** **decodes** **release** **notes**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/07-scheduling-framework" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-7-scheduling-framework-notes.yaml
kubectl get cm -n kube-system 2-10-7-scheduling-framework-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-7-scheduling-framework-notes`** when allowed.

---

## Step 2 — FailedScheduling events as plugin signals (read-only)

**What happens when you run this:**

**Surfaces** **recent** **scheduler** **rejections** **visible** **from** **the** **API** **without** **scheduler** **config** **files**.

**Run:**

```bash
kubectl get events -A --field-selector reason=FailedScheduling 2>/dev/null | tail -n 15 || true
kubectl get pods -A --field-selector=status.phase=Pending -o wide 2>/dev/null | head -n 12 || true
```

**Expected:** **Event** **lines** **with** **messages** **(may** **be** **empty)**; **Pending** **Pods** **if** **any**.

## Video close — fast validation

```bash
kubectl get lease -n kube-system 2>/dev/null | grep -i scheduler | head -n 5 || true
```

## Troubleshooting

- **No** **events** **retained** → **default** **TTL** **expired**—**reproduce** **and** **watch** **`kubectl get events --watch`**
- **Custom** **scheduler** **name** → **`spec.schedulerName`** **must** **match** **running** **scheduler** **instance**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-7-scheduling-framework-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-10-7-scheduling-framework-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.8 Dynamic Resource Allocation](../08-dynamic-resource-allocation/README.md)
