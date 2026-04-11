# 2.4.1.9 User Namespaces â€” teaching transcript

## Intro

On Linux, **user namespaces** **remap** UIDs and GIDs so that **root inside the container** (UID 0) maps to an **unprivileged UID on the host**. That shrinks blast radius if a container escape reaches the host user table. In Kubernetes, **`spec.securityContext`** and the **`hostUsers`** field interact with this feature: **`hostUsers: false`** (where supported) signals that the Pod should use **user-namespace remapping** rather than sharing the host user namespace. Support requires a **recent kernel** (commonly **6.3+** for the full upstream story; distributions vary) and a **container runtime** that enables it (for example **containerd 1.7+** with correct configuration). Many clusters simply do not enable this yetâ€”treat this lesson as **capability planning**, not a universal toggle.

**Prerequisites:** [2.4.1.8 Workload Reference](../09-workload-reference/README.md) recommended.

## Flow of this lesson

```
  Cluster + node kernel + containerd/CRI-O capability
              â”‚
              â–¼
  Pod spec: hostUsers / user namespace mode
              â”‚
              â–¼
  root in container â‰  root on host (when enabled)
```

**Say:**

If the node cannot remap users, the API may accept YAML but kubelet or runtime rejects the podâ€”always validate on real hardware.

## Learning objective

- Explain **user namespace remapping** in one sentence for stakeholders.
- List **kernel** and **runtime** prerequisites at a high level.
- Map **`hostUsers: false`** intent to â€œenable remapping where supported.â€

## Why this matters

Security reviews increasingly ask whether â€œcontainer rootâ€ is still root on the host; this is the technical answer.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.4-workloads/01-pods/10-user-namespaces" 2>/dev/null || cd .
```

## Step 1 â€” Apply notes and confirm

**What happens when you run this:**

Notes land in **kube-system** when RBAC allows.

**Say:**

I read the notes aloud and immediately open the **vendor matrix** for GKE/EKS/AKS because flags differ.

**Run:**

```bash
kubectl apply -f yamls/user-namespaces-notes.yaml
kubectl get configmap user-namespaces-notes -n kube-system
```

**Expected:** Notes ConfigMap is stored for comparing cluster support and constraints.

---

## Step 2 â€” Check server version and nodes

**What happens when you run this:**

`kubectl version` shows **server** minor version; nodes show kernel indirectly in **OS image** (not full `uname`).

**Say:**

Kernel check ultimately needs **node SSH** or a **DaemonSet** diagnosticâ€”kubectl only hints.

**Run:**

```bash
kubectl version -o yaml | sed -n '1,25p'
kubectl get nodes -o wide
```

**Expected:** Server version block present; node list with images and readiness.

## Video close â€” fast validation

```bash
kubectl get configmap user-namespaces-notes -n kube-system -o jsonpath='{.data.notes}' | head -n 15 2>/dev/null || true
kubectl get nodes -o wide
```

## Troubleshooting

- **Pod `CreateContainerError` after enabling** â†’ runtime or kernel unsupported; check release notes
- **hostUsers ignored** â†’ API version or feature gate; upgrade cluster
- **PSA / SCC blocks** â†’ policy may forbid user namespace fields
- **Performance regression** â†’ some remap paths add syscall overhead; measure before fleet-wide enable
- **Notes ConfigMap Forbidden** â†’ skip in-cluster apply; use git copy
- **False sense of security** â†’ pair user namespaces with **readOnlyRootFilesystem**, **drop caps**, and **network policy**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/user-namespaces-notes.yaml` | Support and constraint notes |
| `yamls/failure-troubleshooting.yaml` | Integration and policy gaps |

## Cleanup

```bash
kubectl delete configmap user-namespaces-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.1.10 Downward API](../11-downward-api/README.md)
