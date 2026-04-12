# Pod Overhead — teaching transcript

## Intro

**Pod** **overhead** **accounts** **for** **resources** **the** **runtime** **consumes** **outside** **container** **cgroups** **(sandbox**, **network**, **monitoring** **sidecars** **at** **the** **Pod** **level)** **so** **the** **scheduler** **reserves** **enough** **node** **capacity**. **RuntimeClass** **can** **declare** **overhead** **that** **merges** **into** **the** **Pod** **before** **scheduling**. **Without** **overhead**, **sandboxed** **workloads** **look** **smaller** **than** **they** **are** **and** **cause** **node** **pressure** **later**.

**Prerequisites:** [2.10.2 Assigning Pods to Nodes](../02-assigning-pods-to-nodes/README.md).

## Flow of this lesson

```
  RuntimeClass / Pod overhead fields
              │
              ▼
  Scheduler adds overhead to requests for placement math
              │
              ▼
  Node admits Pod with realistic footprint
```

**Say:**

**Overhead** **is** **not** **a** **trick** **to** **charge** **more**—**it** **prevents** **silent** **overcommit** **on** **sandboxed** **runtimes**.

## Learning objective

- Point to **`pod.spec.overhead`** **in** **the** **API** **and** **relate** **it** **to** **RuntimeClass**.
- Explain **why** **overhead** **affects** **scheduling** **even** **when** **containers** **look** **small**.

## Why this matters

**Security** **teams** **push** **gVisor**/**Kata**; **without** **overhead**, **SRE** **sees** **memory** **pressure** **evictions** **(lesson** **2.10.13)**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/03-pod-overhead" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-3-pod-overhead-notes.yaml
kubectl get cm -n kube-system 2-10-3-pod-overhead-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-3-pod-overhead-notes`** when allowed.

---

## Step 2 — Explain overhead and list RuntimeClasses (read-only)

**What happens when you run this:**

**API** **docs** **plus** **whether** **the** **cluster** **defines** **any** **RuntimeClass**.

**Run:**

```bash
kubectl explain pod.spec.overhead 2>/dev/null | head -n 25 || true
kubectl get runtimeclass 2>/dev/null || true
```

**Expected:** **Overhead** **field** **documentation**; **RuntimeClass** **list** **or** **empty**/**forbidden**.

## Video close — fast validation

```bash
kubectl explain runtimeclass.spec.overhead 2>/dev/null | head -n 20 || true
```

## Troubleshooting

- **No** **RuntimeClass** **CRD** → **older** **cluster** **or** **GKE** **Autopilot** **restrictions**
- **Overhead** **ignored** **in** **custom** **scheduler** **forks** → **platform** **risk**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-3-pod-overhead-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-10-3-pod-overhead-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.4 Pod Scheduling Readiness](../04-pod-scheduling-readiness/README.md)
