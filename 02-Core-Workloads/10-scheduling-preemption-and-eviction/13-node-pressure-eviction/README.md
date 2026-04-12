# Node-pressure Eviction — teaching transcript

## Intro

When **kubelet** **detects** **resource** **pressure** **(memory**, **disk**, **inode**, **PID)**, **it** **sets** **node** **conditions** **and** **may** **evict** **Pods** **to** **reclaim** **space** **according** **to** **QoS** **and** **policy** **(soft** **vs** **hard** **thresholds**, **eviction** **signals)**. **This** **is** **not** **scheduler** **preemption**—**it** **happens** **after** **bind**, **on** **the** **node**, **often** **without** **respecting** **human** **expectations** **if** **requests** **were** **wrong**. **Pods** **that** **ignore** **limits** **still** **die** **when** **the** **node** **is** **under** **pressure**.

**Prerequisites:** [2.10.12 Pod Priority and Preemption](../12-pod-priority-and-preemption/README.md); [2.7.4 Resource management for pods and containers](../../07-configuration/04-resource-management-for-pods-and-containers/README.md).

## Flow of this lesson

```
  Node resource pressure detected
              │
              ▼
  kubelet sets MemoryPressure / DiskPressure / PIDPressure (as applicable)
              │
              ▼
  Eviction manager removes Pods; scheduler may avoid node if tainted
```

**Say:**

**I** **show** **`kubectl describe node`** **Conditions** **side** **by** **side** **with** **`kubectl top pod`** **during** **a** **lab** **spike**.

## Learning objective

- Read **node** **pressure** **conditions** **from** **`kubectl`** **output**.
- Contrast **kubelet** **eviction** **with** **API** **eviction** **(lesson** **2.10.14)** **and** **scheduler** **preemption**.

## Why this matters

**Disk** **pressure** **from** **container** **logs** **evicts** **Pods** **that** **never** **touched** **their** **memory** **limits**—**operators** **need** **that** **mental** **model**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/13-node-pressure-eviction" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-13-node-pressure-eviction-notes.yaml
kubectl get cm -n kube-system 2-10-13-node-pressure-eviction-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-13-node-pressure-eviction-notes`** when allowed.

---

## Step 2 — Node conditions related to pressure (read-only)

**What happens when you run this:**

**JSONPath** **extracts** **`type`,** **`status`,** **`reason`** **for** **quick** **scanning**.

**Run:**

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{range .status.conditions[*]}{.type}{"\t"}{.status}{"\t"}{.reason}{"\n"}{end}{"\n"}{end}' 2>/dev/null | grep -iE 'Pressure|Memory|Disk|PID' | head -n 25 || true
```

**Expected:** **Condition** **lines** **when** **present**; **may** **be** **empty** **on** **healthy** **clusters**.

## Video close — fast validation

```bash
N="$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [ -n "$N" ]; then kubectl describe node "$N" 2>/dev/null | sed -n '/Conditions:/,/Addresses:/p' | head -n 25; fi || true
```

## Troubleshooting

- **`sed` on Windows** → **Git** **Bash** **or** **WSL**, **or** **use** **`kubectl describe`** **manually**
- **Evicted** **Pods** **without** **pressure** **now** → **check** **taints** **NoExecute** **and** **node** **lifecycle**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-13-node-pressure-eviction-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-10-13-node-pressure-eviction-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.14 API-initiated Eviction](../14-api-initiated-eviction/README.md)
