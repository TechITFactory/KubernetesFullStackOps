# 2.6.13 Local Ephemeral Storage — teaching transcript

## Intro

**Local ephemeral storage** covers **container writable layers**, **logs**, **emptyDir**, and **image** layers on the node’s **root** or **image** filesystem. **Requests and limits** on **`ephemeral-storage`** influence **scheduling** and **eviction**: when a Pod or node exceeds pressure thresholds, the kubelet may **evict** Pods—often **BestEffort** or over-quota workloads first ([QoS](../../04-workloads/08-pod-quality-of-service-classes/README.md) ties in). **Monitoring** free space on **/var/lib/kubelet** (or containerd paths) is classic ops work; Kubernetes surfaces **allocatable ephemeral-storage** on **Node** status.

**Prerequisites:** [2.6.12 Node-specific Volume Limits](../12-node-specific-volume-limits/README.md).

## Flow of this lesson

```
  Pod uses ephemeral disk (layers, logs, emptyDir)
              │
              ▼
  Node filesystem pressure thresholds
              │
              ▼
  Eviction / Pod termination if over limit or node pressure
```

**Say:**

**Disk pressure** is as real as **memory pressure**—logs in a tight loop fill disks fast.

## Learning objective

- Name what counts toward **ephemeral-storage** on a node.
- Relate **ephemeral-storage** **limits** to **eviction** behavior at a high level.
- Read **node allocatable** ephemeral storage when present.

## Why this matters

“Pod disappeared overnight” is often **eviction** after **log** or **emptyDir** growth—not a mystery crash.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/13-local-ephemeral-storage" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Local ephemeral storage teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-6-13-local-ephemeral-storage-notes.yaml
kubectl get cm -n kube-system 2-6-13-local-ephemeral-storage-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-13-local-ephemeral-storage-notes` when allowed.

---

## Step 2 — Inspect node capacity and pressure (read-only)

**What happens when you run this:**

**`describe node`** shows **Allocatable** and **conditions** like **DiskPressure**.

**Run:**

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.allocatable.ephemeral-storage}{"\n"}{end}' 2>/dev/null | head -n 15 || true
kubectl describe nodes 2>/dev/null | sed -n '/Conditions:/,/Addresses:/p' | head -n 30 || true
```

**Expected:** Ephemeral storage quantities and condition block (varies by cluster).

## Video close — fast validation

```bash
kubectl top nodes 2>/dev/null | head -n 10 || true
kubectl get pods -A --field-selector=status.phase=Failed 2>/dev/null | head -n 10 || true
```

## Troubleshooting

- **Evicted (DiskPressure)** → rotate logs, raise limits, or add **PVC** for heavy write paths
- **No ephemeral limit set** → still vulnerable to **node** pressure—set **Pod** limits for noisy neighbors
- **Image garbage collection** → kubelet frees space—may surprise pull latency
- **Wrong mount** → bind mounts can hide **df** output—SSH node for truth
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-6-13-local-ephemeral-storage-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-13-local-ephemeral-storage-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.14 Volume Health Monitoring](../14-volume-health-monitoring/README.md)
