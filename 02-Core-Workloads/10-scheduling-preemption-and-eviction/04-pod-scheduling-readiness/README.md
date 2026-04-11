# 2.10.4 Pod Scheduling Readiness — teaching transcript

## Intro

**Scheduling** **gates** **(Pod** **`schedulingGates`)** **hold** **a** **Pod** **in** **`SchedulingGated`** **state** **so** **controllers** **can** **prepare** **dependencies** **(reservations**, **external** **approvals**, **fencing**) **before** **the** **scheduler** **sees** **it** **as** **ready**. **Removing** **all** **gates** **allows** **normal** **scheduling**. **This** **differs** **from** **`spec.nodeName`** **being** **set** **or** **taints** **blocking** **placement**—**here** **the** **scheduler** **intentionally** **waits**.

**Prerequisites:** [2.10.3 Pod Overhead](../03-pod-overhead/README.md).

## Flow of this lesson

```
  Controller adds schedulingGates on Pod
              │
              ▼
  Pod not schedulable until gates cleared
              │
              ▼
  Gates removed → standard scheduling queue
```

**Say:**

**Batch** **systems** **and** **DRA-style** **flows** **use** **gates** **to** **avoid** **binding** **Pods** **before** **resources** **exist**.

## Learning objective

- Use **`kubectl explain`** **for** **`pod.spec.schedulingGates`**.
- Contrast **gated** **Pods** **with** **Pending** **Pods** **blocked** **by** **affinity** **or** **resources**.

## Why this matters

**Misunderstanding** **gates** **leads** **to** **“scheduler** **is** **broken”** **tickets** **when** **a** **controller** **never** **released** **the** **gate**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/04-pod-scheduling-readiness" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-4-pod-scheduling-readiness-notes.yaml
kubectl get cm -n kube-system 2-10-4-pod-scheduling-readiness-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-4-pod-scheduling-readiness-notes`** when allowed.

---

## Step 2 — Explain scheduling gates (read-only)

**What happens when you run this:**

Shows **API** **shape** **for** **gate** **names** **and** **semantics**.

**Run:**

```bash
kubectl explain pod.spec.schedulingGates 2>/dev/null | head -n 30 || true
kubectl get pods -A 2>/dev/null | head -n 5 || true
```

**Expected:** **Explain** **output**; **unrelated** **pod** **sample** **(gated** **Pods** **are** **rare** **on** **idle** **clusters)**.

## Video close — fast validation

```bash
kubectl explain pod.status.conditions 2>/dev/null | head -n 20 || true
```

## Troubleshooting

- **Feature** **not** **available** → **upgrade** **cluster** **or** **skip** **live** **`explain`**
- **Stuck** **gate** → **inspect** **controller** **logs** **that** **own** **the** **gate** **name**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-4-pod-scheduling-readiness-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-10-4-pod-scheduling-readiness-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.5 Pod Topology Spread Constraints](../05-pod-topology-spread-constraints/README.md)
