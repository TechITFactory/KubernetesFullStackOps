# 2.12.1 Windows containers in Kubernetes — teaching transcript

## Intro

**Windows** **containers** **use** **the** **Windows** **kernel** **and** **require** **Windows** **Server** **or** **Windows** **container** **runtime** **support** **on** **the** **node**. **They** **do** **not** **run** **on** **Linux** **nodes** **even** **with** **the** **same** **image** **name** **tag**. **Hybrid** **clusters** **typically** **run** **Linux** **control** **plane** **components** **with** **a** **mix** **of** **Linux** **and** **Windows** **workers**. **GMSA**, **hostProcess** **containers**, **and** **specific** **volume** **types** **are** **advanced** **topics** **touched** **in** **the** **next** **lesson**.

**Prerequisites:** [2.12 module](../README.md); [2.3 Containers](../03-containers/README.md) **(images** **and** **runtime** **vocabulary)**.

## Flow of this lesson

```
  Windows image + Windows node + compatible CNI path
              │
              ▼
  kubelet + containerd / Mirantis runtime on Windows
              │
              ▼
  Pod Running with Windows-specific constraints
```

**Say:**

**Linux** **and** **Windows** **containers** **sharing** **a** **cluster** **is** **normal**; **sharing** **a** **node** **is** **not**.

## Learning objective

- Identify **Windows** **nodes** **via** **`kubernetes.io/os=windows`** **and** **related** **labels**.
- State **image** **OS**/**architecture** **requirements** **for** **Windows** **workloads**.

## Why this matters

**Build** **pipelines** **that** **only** **test** **Linux** **images** **ship** **broken** **Windows** **manifests** **to** **production**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/12-windows-in-kubernetes/01-windows-containers-in-kubernetes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-12-1-windows-containers-in-kubernetes-notes.yaml
kubectl get cm -n kube-system 2-12-1-windows-containers-in-kubernetes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-12-1-windows-containers-in-kubernetes-notes`** when allowed.

---

## Step 2 — Node OS inventory (read-only)

**What happens when you run this:**

**Lists** **node** **OS** **and** **Windows** **build** **label** **when** **the** **cluster** **has** **Windows** **workers**.

**Run:**

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.kubernetes\.io/os}{"\t"}{.metadata.labels.node\.kubernetes\.io/windows-build}{"\n"}{end}' 2>/dev/null | head -n 20 || true
kubectl get nodes -l kubernetes.io/os=windows 2>/dev/null | head -n 10 || true
```

**Expected:** **Tab-separated** **rows**; **Windows** **filter** **table** **or** **“No** **resources** **found”**.

## Video close — fast validation

```bash
kubectl get nodes --show-labels 2>/dev/null | grep -i windows | head -n 5 || true
```

## Troubleshooting

- **No** **Windows** **nodes** → **use** **AKS**/**EKS**/**GKE** **Windows** **pool** **docs** **for** **demos**
- **`node.kubernetes.io/windows-build` missing** → **older** **clusters** **or** **custom** **labels**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-12-1-windows-containers-in-kubernetes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-12-1-windows-containers-in-kubernetes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.12.2 Guide for running Windows containers in Kubernetes](../02-guide-for-running-windows-containers-in-kubernetes/README.md)
