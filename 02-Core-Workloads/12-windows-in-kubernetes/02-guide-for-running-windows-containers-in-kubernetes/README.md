# Guide for running Windows containers in Kubernetes — teaching transcript

## Intro

**Running** **Windows** **containers** **well** **requires** **correct** **`nodeSelector`**, **tolerations** **for** **Windows** **taints**, **compatible** **CNIs**, **DNS** **and** **Service** **behavior** **awareness**, **and** **often** **GMSA** **for** **Active** **Directory** **integrated** **apps**. **Resource** **limits**, **health** **probes**, **and** **storage** **classes** **differ** **from** **Linux** **patterns**—**follow** **vendor** **guides** **for** **your** **cloud** **or** **on-prem** **distribution**.

**Prerequisites:** [2.12.1 Windows containers in Kubernetes](../01-windows-containers-in-kubernetes/README.md); [2.10.6 Taints and tolerations](../../10-scheduling-preemption-and-eviction/06-taints-and-tolerations/README.md).

## Flow of this lesson

```
  Namespace + workload manifest with OS selectors / tolerations
              │
              ▼
  Pull Windows image matching node build / runtime
              │
              ▼
  Validate networking, storage, and identity integrations
```

**Say:**

**I** **keep** **one** **golden** **Windows** **Deployment** **YAML** **in** **git** **with** **comments** **for** **every** **selector** **line**—**students** **copy** **that**, **not** **random** **blog** **snippets**.

## Learning objective

- Sketch **a** **valid** **Pod** **or** **Deployment** **fragment** **for** **Windows** **(selectors**, **tolerations)**.
- Point **to** **`kubectl explain pod.spec`** **fields** **relevant** **to** **hostProcess** **and** **securityContext** **(awareness)**.

## Why this matters

**Production** **Windows** **on** **Kubernetes** **fails** **on** **identity**, **DNS**, **or** **CNI** **details**—**not** **on** **`image:` lines alone**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/12-windows-in-kubernetes/02-guide-for-running-windows-containers-in-kubernetes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-12-2-guide-for-running-windows-containers-in-kubernetes-notes.yaml
kubectl get cm -n kube-system 2-12-2-guide-for-running-windows-containers-in-kubernetes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-12-2-guide-for-running-windows-containers-in-kubernetes-notes`** when allowed.

---

## Step 2 — Sample Windows workload discovery (read-only)

**What happens when you run this:**

**Looks** **for** **running** **Windows** **Pods** **without** **creating** **anything**.

**Run:**

```bash
kubectl get pods -A -o wide 2>/dev/null | grep -i windows | head -n 15 || true
kubectl get pods -A --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{" os="}{.spec.nodeSelector.kubernetes\.io/os}{"\n"}{end}' 2>/dev/null | grep -i windows | head -n 10 || true
```

**Expected:** **Matches** **or** **empty** **clusters**.

## Video close — fast validation

```bash
kubectl explain pod.spec.nodeSelector 2>/dev/null | head -n 12 || true
```

## Troubleshooting

- **`ImagePullBackOff`** → **wrong** **registry**, **credentials**, **or** **OS** **or** **arch** **mismatch**
- **Service** **connectivity** **differs** → **CNI** **Windows** **HNS** **policies** **or** **vendor** **docs**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-12-2-guide-for-running-windows-containers-in-kubernetes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-12-2-guide-for-running-windows-containers-in-kubernetes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.13 Extending Kubernetes](../../13-extending-kubernetes/README.md)
