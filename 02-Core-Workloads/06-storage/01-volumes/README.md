# Volumes — teaching transcript

## Intro

A **volume** is a directory (or file tree) **mounted into a container** in a Pod. Unlike a container’s writable layer, volumes can **outlive a single container restart** inside the same Pod (for example **emptyDir** until the Pod is deleted) or **reference cluster objects** (**configMap**, **secret**, **downwardAPI**). **hostPath** binds a path on the **node**—powerful for agents, dangerous for portable apps because data and permissions differ per machine. Understanding **volume sources** is prerequisite to **PVCs**: persistent claims are just another volume type from the Pod’s perspective.

**Prerequisites:** [2.6 Storage module](../README.md); Pods and containers from [04-workloads](../../04-workloads/README.md).

## Flow of this lesson

```
  Pod spec.volumes[]
        │
        ▼
  volumeMounts[] in containers
        │
        ▼
  Runtime mounts source (emptyDir, CM, Secret, …)
```

**Say:**

I always say “volume is declared at **Pod** level, mounted per **container**”—two different stanzas.

## Learning objective

- Name common **in-tree** volume sources: **emptyDir**, **configMap**, **secret**, **downwardAPI**, **hostPath** (with caveats).
- Explain **ephemeral vs node-local** behavior for **emptyDir** vs **hostPath**.

## Why this matters

Misused **hostPath** breaks portability; missing **readOnly** on **secret** mounts causes surprise writes and security findings.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/01-volumes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Stores teaching notes in **kube-system** when RBAC allows.

**Say:**

If **Forbidden**, open `yamls/2-6-1-volumes-notes.yaml` from the repo and teach without applying.

**Run:**

```bash
kubectl apply -f yamls/2-6-1-volumes-notes.yaml
kubectl get cm -n kube-system 2-6-1-volumes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-1-volumes-notes` in `kube-system`, or apply denied on locked-down clusters.

---

## Step 2 — Inventory cluster storage-related objects (read-only)

**What happens when you run this:**

Lists **PV** and **PVC** if any exist—often empty on tutorial clusters.

**Say:**

Even in a “volumes” lesson, I glance at **PVC** count so the audience sees the handoff to the next lesson.

**Run:**

```bash
kubectl get pv 2>/dev/null | head -n 15 || true
kubectl get pvc -A 2>/dev/null | head -n 15 || true
```

**Expected:** Table output or empty; no cluster mutation.

## Video close — fast validation

```bash
kubectl get cm -n kube-system 2-6-1-volumes-notes -o yaml 2>/dev/null | sed -n '1,25p' || true
kubectl api-resources | grep -i persistentvolume | head -n 5 || true
```

## Troubleshooting

- **`kube-system` apply denied** → narrate from git-only YAML
- **Confuse volume vs mount** → show Pod YAML: **`volumes`** vs **`volumeMounts`**
- **emptyDir “lost my data”** → expected after Pod delete—move to **PVC** ([2.6.2](../02-persistent-volumes/README.md))
- **hostPath not portable** → document node name and path for ops-only use cases
- **Secret not updating** → mounted secrets can be **optional**; propagation depends on source

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-6-1-volumes-notes.yaml` | In-cluster notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-1-volumes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.2 Persistent Volumes](../02-persistent-volumes/README.md)
