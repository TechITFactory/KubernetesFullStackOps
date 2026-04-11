# 2.11.10 Compatibility version for Kubernetes control plane components — teaching transcript

## Intro

**Kubernetes** **control** **plane** **components** **(apiserver**, **scheduler**, **controller-manager**, **kubelet**, **kubectl)** **must** **stay** **within** **supported** **skew** **windows** **per** **release** **notes**. **Compatibility** **version** **features** **help** **roll** **out** **new** **API** **defaults** **without** **breaking** **older** **clients**. **Admins** **verify** **versions** **during** **upgrades** **and** **when** **debugging** **mysterious** **field** **validation** **errors**.

**Prerequisites:** [2.11.9 Logging architecture](../09-logging-architecture/README.md).

## Flow of this lesson

```
  Release notes define supported skew
              │
              ▼
  Upgrade order: apiserver before kubelets (typical)
              │
              ▼
  Feature gates and compatibility settings smooth transitions
```

**Say:**

**I** **paste** **`kubectl version`** **into** **the** **upgrade** **ticket** **so** **audit** **trails** **show** **exactly** **what** **ran**.

## Learning objective

- Read **client** **and** **server** **version** **info** **with** **`kubectl version`**.
- Explain **why** **kubelet** **must** **not** **leap** **ahead** **of** **apiserver**.

## Why this matters

**Unsupported** **skew** **manifests** **as** **random** **`Forbidden`** **or** **field** **drop** **bugs** **that** **waste** **days**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/10-compatibility-version-for-kubernetes-control-plane-components" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-10-compatibility-version-for-kubernetes-control-plane-components-notes.yaml
kubectl get cm -n kube-system 2-11-10-compatibility-version-for-kubernetes-control-plane-components-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-10-compatibility-version-for-kubernetes-control-plane-components-notes`** when allowed.

---

## Step 2 — Server and node kubelet versions (read-only)

**What happens when you run this:**

**Compares** **apiserver** **GitVersion** **to** **node** **kubelet** **versions** **in** **`kubectl get nodes`**.

**Run:**

```bash
kubectl version -o yaml 2>/dev/null | head -n 40 || true
kubectl get nodes -o custom-columns=NAME:.metadata.name,KUBELET:.status.nodeInfo.kubeletVersion 2>/dev/null | head -n 15 || true
```

**Expected:** **Version** **YAML** **snippet**; **per-node** **kubelet** **version** **column**.

## Video close — fast validation

```bash
kubectl version --short 2>/dev/null || kubectl version 2>/dev/null | head -n 8 || true
```

## Troubleshooting

- **Wide** **kubelet** **spread** → **rolling** **node** **pool** **upgrade** **plan**
- **Server** **version** **unknown** → **auth** **or** **network** **to** **apiserver**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-10-compatibility-version-for-kubernetes-control-plane-components-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-11-10-compatibility-version-for-kubernetes-control-plane-components-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.11 Metrics for Kubernetes system components](../11-metrics-for-kubernetes-system-components/README.md)
