# ConfigMaps — teaching transcript

## Intro

A **ConfigMap** stores **configuration** as string data or binary-like file chunks (**immutable** option can freeze updates for rollout safety). Pods consume ConfigMaps as **environment variables** (`valueFrom.configMapKeyRef`), as **files** (`volumes` of type **configMap**), or inside **projected** volumes. Updates propagate to mounted files on a **kubelet sync** interval—not always instant. **ConfigMap** is **not** for passwords: use **Secrets** ([2.7.2](../02-secrets/README.md)). Size limits apply (typically **1 MiB** total)—large configs belong in **git** + **volume** or an external store.

**Prerequisites:** [2.7 Configuration module](../README.md); Pods and volumes from [04-workloads](../../04-workloads/README.md).

## Flow of this lesson

```
  ConfigMap (namespace-scoped)
              │
              ├── envFrom / valueFrom
              └── volumeMount → files
              │
              ▼
  Containers read config at runtime
```

**Say:**

I repeat: **ConfigMap** in **etcd** is **not encrypted** by default like a vault—just non-secret app settings.

## Learning objective

- Create or inspect **ConfigMaps** and relate them to **Pod** env and volume mounts.
- Explain **size** and **immutability** constraints at a high level.

## Why this matters

Twelve-factor apps expect **config outside the image**; ConfigMap is the native knob for that on Kubernetes.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/07-configuration/01-configmaps" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Stores teaching notes in **kube-system** when RBAC allows.

**Say:**

If **Forbidden**, open `yamls/2-7-1-configmaps-notes.yaml` from git and narrate without applying.

**Run:**

```bash
kubectl apply -f yamls/2-7-1-configmaps-notes.yaml
kubectl get cm -n kube-system 2-7-1-configmaps-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-7-1-configmaps-notes` in `kube-system`, or apply denied on managed clusters.

---

## Step 2 — Run inspect script

**What happens when you run this:**

Lists **ConfigMaps** in all namespaces—read-only.

**Run:**

```bash
bash scripts/inspect-2-7-1-configmaps.sh
```

**Expected:** Table of ConfigMaps cluster-wide; script exits 0.

---

## Step 3 — Explain ConfigMap pod fields (read-only)

**What happens when you run this:**

**`kubectl explain`** shows how Pods reference ConfigMaps.

**Run:**

```bash
kubectl explain pod.spec.containers.env.valueFrom.configMapKeyRef 2>/dev/null | head -n 20 || true
kubectl explain pod.spec.volumes.configMap 2>/dev/null | head -n 20 || true
```

**Expected:** API documentation snippets for your server version.

## Video close — fast validation

```bash
kubectl get configmaps -A 2>/dev/null | head -n 20
kubectl explain configmap 2>/dev/null | head -n 18
```

## Troubleshooting

- **`CreateContainerConfigError`** → missing **ConfigMap** key or wrong **name**/**namespace**
- **Stale file in pod** → wait for kubelet sync or restart pod after CM update
- **Too large** → split config or use **gitRepo** pattern / external config server (not deprecated APIs without replacement plan)
- **Wrong namespace** → ConfigMaps are **namespaced**—reference with `configMapRef` in same ns or use **RBAC** for reads
- **`Forbidden` kube-system** → skip apply; teach from repo YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-7-1-configmaps.sh` | `kubectl get configmaps -A` |
| `yamls/2-7-1-configmaps-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-7-1-configmaps-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.7.2 Secrets](../02-secrets/README.md)
