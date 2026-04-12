# Gang Scheduling — teaching transcript

## Intro

**Gang** **scheduling** **means** **scheduling** **a** **group** **of** **Pods** **together** **(all-or-nothing** **or** **minimum** **parallelism)** **so** **distributed** **jobs** **do** **not** **start** **partial** **members** **and** **waste** **cluster** **resources** **or** **deadlock**. **Core** **kube-scheduler** **does** **not** **ship** **a** **full** **gang** **scheduler** **for** **every** **workload** **type**—**teams** **use** **projects** **like** **Volcano**, **Kueue**, **or** **MPI** **operators** **that** **implement** **queuing** **and** **coscheduling** **semantics** **above** **or** **beside** **default** **scheduling**.

**Prerequisites:** [2.10.8 Dynamic Resource Allocation](../08-dynamic-resource-allocation/README.md).

## Flow of this lesson

```
  Job controller creates N Pods with gang semantics (external or built-in)
              │
              ▼
  Scheduler / queue holds Pods until quorum satisfied
              │
              ▼
  Group starts together; avoids partial placements
```

**Say:**

**I** **use** **a** **toy** **diagram** **with** **four** **workers** **and** **one** **driver**—**if** **only** **two** **workers** **land**, **the** **job** **should** **not** **run**.

## Learning objective

- Explain **why** **gang** **scheduling** **matters** **for** **batch** **and** **ML** **training** **jobs**.
- Point **to** **Pending** **Pods** **and** **events** **as** **observable** **symptoms** **of** **queuing** **or** **unsatisfied** **quorum**.

## Why this matters

**Partial** **placements** **burn** **GPU** **hours** **and** **leave** **stranded** **memory** **reservations** **that** **Quota** **still** **counts**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/09-gang-scheduling" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-9-gang-scheduling-notes.yaml
kubectl get cm -n kube-system 2-10-9-gang-scheduling-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-9-gang-scheduling-notes`** when allowed.

---

## Step 2 — Observe Pending workloads and batch-style controllers (read-only)

**What happens when you run this:**

**Surfaces** **Pods** **that** **might** **be** **held** **by** **external** **schedulers** **(names** **often** **include** **job**/**worker**/**task)**.

**Run:**

```bash
kubectl get pods -A --field-selector=status.phase=Pending -o wide 2>/dev/null | head -n 20 || true
kubectl api-resources 2>/dev/null | grep -iE 'job|queue|workload' | head -n 20 || true
```

**Expected:** **Pending** **rows** **(may** **be** **empty)**; **CRD** **names** **vary** **by** **cluster**.

## Video close — fast validation

```bash
kubectl get jobs -A 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **Everything** **Pending** **forever** → **quota**, **gates**, **or** **queue** **plugin** **config**
- **Vendor** **operator** **missing** → **install** **or** **use** **smaller** **replica** **counts** **for** **demos**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-9-gang-scheduling-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-10-9-gang-scheduling-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.10 Scheduler Performance Tuning](../10-scheduler-performance-tuning/README.md)
