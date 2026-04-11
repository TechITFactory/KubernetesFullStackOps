# 2.11.3 Node autoscaling — teaching transcript

## Intro

**Cluster** **autoscaler** **(and** **vendor** **equivalents)** **adds** **or** **removes** **nodes** **based** **on** **unschedulable** **Pods**, **utilization**, **and** **cloud** **quotas**. **It** **does** **not** **replace** **HPA**—**CA** **scales** **the** **fleet**, **HPA** **scales** **replica** **counts**. **Labels**, **taints**, **GPU** **pools**, **and** **zones** **must** **align** **with** **autoscaler** **configuration** **or** **Pods** **stay** **Pending** **while** **nodes** **spin** **up** **uselessly**.

**Prerequisites:** [2.11.2 Swap memory management](../02-swap-memory-management/README.md); [2.10 Scheduling](../../10-scheduling-preemption-and-eviction/README.md).

## Flow of this lesson

```
  Pending Pods / utilization signals
              │
              ▼
  Autoscaler evaluates node groups
              │
              ▼
  Cloud API adds or removes instances; nodes join cluster
```

**Say:**

**I** **show** **one** **`FailedScheduling`** **event** **that** **mentions** **insufficient** **CPU** **then** **watch** **a** **node** **join**—**that** **is** **the** **CA** **happy** **path**.

## Learning objective

- Contrast **cluster** **autoscaler** **with** **horizontal** **Pod** **autoscaler**.
- Run **repo** **inspect** **script** **and** **interpret** **node** **capacity** **columns**.

## Why this matters

**Mis-sized** **node** **groups** **burn** **money** **or** **block** **deployments** **during** **traffic** **spikes**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/03-node-autoscaling" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-3-node-autoscaling-notes.yaml
kubectl get cm -n kube-system 2-11-3-node-autoscaling-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-3-node-autoscaling-notes`** when allowed.

---

## Step 2 — Node inventory (read-only)

**What happens when you run this:**

**Script** **lists** **nodes** **with** **wide** **columns** **(zones**, **versions)** **for** **pool** **discussion**.

**Run:**

```bash
bash scripts/inspect-2-11-3-node-autoscaling.sh 2>/dev/null || kubectl get nodes -o wide 2>/dev/null | head -n 15 || true
kubectl get events -A --field-selector reason=FailedScheduling 2>/dev/null | tail -n 8 || true
```

**Expected:** **Node** **rows**; **optional** **scheduling** **events**.

## Video close — fast validation

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints --no-headers 2>/dev/null | head -n 10 || true
```

## Troubleshooting

- **CA** **does** **nothing** → **Pod** **cannot** **fit** **any** **template** **(GPU**, **affinity)**
- **Flapping** **nodes** → **thresholds**, **spot** **pricing**, **PDB** **interaction**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-3-node-autoscaling-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-11-3-node-autoscaling.sh` | **`kubectl get nodes -o wide`** |

## Cleanup

```bash
kubectl delete configmap 2-11-3-node-autoscaling-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.4 Certificates](../04-certificates/README.md)
