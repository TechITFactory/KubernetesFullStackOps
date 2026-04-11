# 2.10.2 Assigning Pods to Nodes — teaching transcript

## Intro

**Node selection** **layers** **stack**: **`nodeSelector`** **(simple** **label** **match)**, **affinity** **and** **anti-affinity** **(required** **vs** **preferred** **rules** **with** **topology)**, and **implicit** **filters** **(taints**, **resources**, **runtime**, **volumes)**. **Required** **affinity** **that** **cannot** **be** **satisfied** **keeps** **Pods** **Pending** **forever** **until** **labels** **or** **rules** **change**. **Preferred** **rules** **soften** **placement** **without** **blocking** **scheduling**.

**Prerequisites:** [2.10.1 Kubernetes Scheduler](../01-kubernetes-scheduler/README.md).

## Flow of this lesson

```
  Pod spec: nodeSelector / affinity / anti-affinity
              │
              ▼
  Scheduler matches node labels + topology (zone, host, …)
              │
              ▼
  Taints and resources still apply (next lessons reinforce)
```

**Say:**

I **draw** **the** **difference** **between** **“must”** **(requiredDuringScheduling)** **and** **“should”** **(preferredDuringScheduling)** **on** **the** **whiteboard** **before** **opening** **YAML**.

## Learning objective

- Use **`kubectl explain`** **for** **`pod.spec.affinity`** **and** **`nodeSelector`**.
- Relate **node** **taints** **(inspect** **script)** **to** **whether** **affinity** **alone** **can** **place** **a** **Pod**.

## Why this matters

**Anti-affinity** **without** **enough** **nodes** **blocks** **rollouts** **at** **the** **worst** **moment**—**capacity** **planning** **is** **part** **of** **the** **policy**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/02-assigning-pods-to-nodes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-2-assigning-pods-to-nodes-notes.yaml
kubectl get cm -n kube-system 2-10-2-assigning-pods-to-nodes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-2-assigning-pods-to-nodes-notes`** when allowed.

---

## Step 2 — Node taints and affinity API shape (read-only)

**What happens when you run this:**

**Taints** **reduce** **eligible** **nodes** **even** **when** **affinity** **matches** **labels**; **`explain`** **shows** **affinity** **fields**.

**Run:**

```bash
bash scripts/inspect-2-10-2-assigning-pods-to-nodes.sh 2>/dev/null || true
kubectl explain pod.spec.affinity 2>/dev/null | head -n 30 || true
kubectl get nodes --show-labels 2>/dev/null | head -n 8 || true
```

**Expected:** **Taints** **column** **per** **node**; **affinity** **docs**; **truncated** **label** **rows**.

## Video close — fast validation

```bash
kubectl explain pod.spec.nodeSelector 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **`FailedScheduling: didn’t match affinity`** → **fix** **labels** **or** **relax** **rules**
- **Script** **shows** **`<none>`** **taints** → **normal** **on** **fresh** **clusters**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-2-assigning-pods-to-nodes-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-10-2-assigning-pods-to-nodes.sh` | **Nodes** **with** **taints** **column** |

## Cleanup

```bash
kubectl delete configmap 2-10-2-assigning-pods-to-nodes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.3 Pod Overhead](../03-pod-overhead/README.md)
