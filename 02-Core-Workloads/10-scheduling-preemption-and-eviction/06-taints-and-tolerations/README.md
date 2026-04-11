# 2.10.6 Taints and Tolerations — teaching transcript

## Intro

**Taints** **on** **nodes** **repel** **Pods** **unless** **those** **Pods** **tolerate** **the** **taint** **(match** **`key`,** **`operator`,** **`value`,** **`effect`)**. **Effects** **include** **`NoSchedule`**, **`PreferNoSchedule`**, **and** **`NoExecute`** **(evicts** **running** **Pods** **without** **tolerations** **when** **the** **taint** **appears** **or** **toleration** **expires)**. **Control** **plane** **nodes** **often** **carry** **`NoSchedule`** **taints** **so** **user** **workloads** **stay** **off** **them** **unless** **explicitly** **tolerated**.

**Prerequisites:** [2.10.5 Pod Topology Spread Constraints](../05-pod-topology-spread-constraints/README.md).

## Flow of this lesson

```
  Node taint applied
              │
              ▼
  Scheduler skips node unless Pod tolerates
              │
              ▼
  NoExecute can evict existing Pods
```

**Say:**

**Spot** **/** **preemptible** **node** **pools** **use** **taints** **plus** **tolerations** **to** **target** **batch** **workloads** **without** **accidentally** **landing** **stateful** **apps** **there**.

## Learning objective

- Read **node** **taints** **with** **`kubectl`** **and** **explain** **`pod.spec.tolerations`** **with** **`kubectl explain`**.
- Contrast **`NoSchedule`** **with** **`NoExecute`**.

## Why this matters

**Draining** **nodes** **and** **spot** **instances** **are** **both** **taint** **stories**—**mis-tolerations** **cause** **surprise** **evictions** **or** **stuck** **Pending** **Pods**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/06-taints-and-tolerations" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-6-taints-and-tolerations-notes.yaml
kubectl get cm -n kube-system 2-10-6-taints-and-tolerations-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-6-taints-and-tolerations-notes`** when allowed.

---

## Step 2 — Inspect taints and explain tolerations (read-only)

**What happens when you run this:**

**Same** **node** **taints** **view** **as** **lesson** **2.10.2** **(shared** **pattern)** **plus** **toleration** **schema**.

**Run:**

```bash
bash scripts/inspect-2-10-6-taints-and-tolerations.sh 2>/dev/null || true
kubectl explain pod.spec.tolerations 2>/dev/null | head -n 35 || true
```

**Expected:** **Taints** **per** **node**; **toleration** **field** **docs**.

## Video close — fast validation

```bash
kubectl describe node 2>/dev/null | grep -i taint | head -n 15 || true
```

## Troubleshooting

- **`kubectl taint` left** **a** **typo** → **re-taint** **with** **`-`** **suffix** **to** **remove**
- **System** **Pods** **Pending** → **missing** **tolerations** **for** **control-plane** **taints**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-6-taints-and-tolerations-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-10-6-taints-and-tolerations.sh` | **Nodes** **with** **taints** **column** |

## Cleanup

```bash
kubectl delete configmap 2-10-6-taints-and-tolerations-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.7 Scheduling Framework](../07-scheduling-framework/README.md)
