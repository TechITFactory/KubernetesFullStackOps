# Device plugins — teaching transcript

## Intro

**Device** **plugins** **register** **hardware** **with** **the** **kubelet** **(GPUs**, **FPGAs**, **InfiniBand**, **custom** **ASICs)** **via** **a** **Unix** **socket** **protocol**, **advertising** **allocatable** **extended** **resources** **on** **nodes**. **Pods** **request** **those** **resources** **in** **`resources.limits`**. **This** **predates** **full** **DRA** **workflows** **but** **remains** **ubiquitous** **for** **GPUs**.

**Prerequisites:** [2.13.1.1 Network plugins](../02-network-plugins/README.md); [2.10.15 Node declared features](../../10-scheduling-preemption-and-eviction/15-node-declared-features/README.md).

## Flow of this lesson

```
  Device plugin DaemonSet on node
              │
              ▼
  kubelet publishes extended resources in Node allocatable
              │
              ▼
  Scheduler places Pods requesting those resources
```

**Say:**

**If** **`kubectl describe node` shows** **`nvidia.com/gpu`**, **something** **registered** **successfully**—**if** **not**, **the** **DaemonSet** **or** **driver** **is** **the** **bug**.

## Learning objective

- Find **extended** **resource** **keys** **in** **`Node.status.allocatable`** **(read-only)**.
- Explain **how** **device** **plugins** **relate** **to** **DRA** **(conceptual** **evolution)**.

## Why this matters

**GPU** **jobs** **Pending** **forever** **usually** **means** **plugin** **or** **driver**, **not** **Kubernetes** **“scheduling** **bugs”**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/13-extending-kubernetes/03-device-plugins" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-13-1-2-device-plugins-notes.yaml
kubectl get cm -n kube-system 2-13-1-2-device-plugins-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-13-1-2-device-plugins-notes`** when allowed.

---

## Step 2 — Extended resources on nodes (read-only)

**What happens when you run this:**

**Prints** **allocatable** **map** **per** **node** **and** **filters** **non-standard** **keys**.

**Run:**

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{": "}{range $k,$v := .status.allocatable}{ $k }={ $v } {end}{"\n"}{end}' 2>/dev/null | grep -vE 'cpu=|memory=|pods=|ephemeral-storage=' | head -n 15 || true
```

**Expected:** **Lines** **with** **GPU**/**vendor** **resources** **or** **empty** **filter** **result**.

## Video close — fast validation

```bash
kubectl explain pod.spec.containers.resources.limits 2>/dev/null | head -n 20 || true
```

## Troubleshooting

- **Plugin** **socket** **missing** **on** **node** → **DaemonSet** **not** **scheduled** **there**
- **Version** **skew** **driver** **vs** **kubelet** → **node** **image** **pinning**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-13-1-2-device-plugins-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-13-1-2-device-plugins-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.13.2 Extending the Kubernetes API](../04-extending-the-kubernetes-api/README.md)
