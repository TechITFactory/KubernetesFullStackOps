# 2.4.1.4 Ephemeral Containers — teaching transcript

## Intro

**Ephemeral containers** are **debug-only** containers attached to an **existing Pod**; they are **not** part of the original `spec.containers` and are **not restartable** as a long-lived app component. You add them with **`kubectl debug`**, typically **`--image=busybox`** (or your org’s debug image), and **`--target=<container>`** to share process namespaces with a running container when you need **`gdb`**, **`nsenter`**, or shared **`/proc`**. **`shareProcessNamespace: true`** on the Pod (set at creation time) lets containers see each other’s processes—ephemeral debug attaches into that picture. You **cannot remove** an ephemeral container from a Pod without **recreating** the Pod object; production workloads usually tolerate delete/recreate on a test replica, not on a singleton DB primary.

**Prerequisites:** [2.4.1.3 Sidecar Containers](../2.4.1.3-sidecar-containers/README.md) recommended.

## Flow of this lesson

```
  Running Pod
      │
      ▼
  kubectl debug --image=... [--target=app-container]
      │
      ▼
  Ephemeral container runs (debug session)
      │
      ▼
  Remove only by Pod delete/recreate (no patch-away)
```

**Say:**

Ephemeral containers are the supported answer to “SSH into the pod” without baking SSH into images.

## Learning objective

- Use **`kubectl debug`** with **`--image`** and **`--target`** for interactive troubleshooting.
- Explain why ephemeral containers are **not** a substitute for normal workload containers.
- Relate **`shareProcessNamespace`** to cross-container debugging.

## Why this matters

Without this tool, teams bake debug binaries into every image or break policy by `kubectl exec` into minimal images that lack tools.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.4-workloads/2.4.1-pods/2.4.1.4-ephemeral-containers" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Stores teaching notes in **kube-system** for clusters that allow it.

**Say:**

If this returns **Forbidden**, read the YAML from git and skip apply—managed clusters often lock **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/ephemeral-container-notes.yaml
kubectl get configmap ephemeral-container-notes -n kube-system
```

**Expected:** Notes ConfigMap exists in `kube-system` for review during debugging workflows.

---

## Step 2 — Create a throwaway Pod for debug practice

**What happens when you run this:**

A minimal **busybox** Pod runs `sleep` so you have a target for **`kubectl debug`**.

**Say:**

I use a disposable Pod so I do not attach debug sessions to production workloads on camera.

**Run:**

```bash
kubectl run ephemeral-lesson-target --image=busybox:1.36 --restart=Never -- sleep 3600
kubectl wait --for=condition=Ready pod/ephemeral-lesson-target --timeout=120s
```

**Expected:** Pod **Ready**; container name usually matches pod name (`ephemeral-lesson-target`).

---

## Step 3 — Attach an ephemeral debug container (optional interactive)

**What happens when you run this:**

`kubectl debug` adds an ephemeral container targeting the main container’s namespaces. Omit **`-it`** in scripts; use **`-it`** when teaching live.

**Say:**

Replace **`ephemeral-lesson-target`** with your real pod and **target** with the **container name** from `kubectl get pod POD -o jsonpath='{.spec.containers[*].name}'`.

**Run:**

```bash
kubectl debug ephemeral-lesson-target -it --image=busybox:1.36 --target=ephemeral-lesson-target -- sh
```

**Expected:** Interactive shell (when `-it` used); type `exit` to leave. Ephemeral container remains listed in status until Pod is deleted.

## Video close — fast validation

```bash
kubectl get cm ephemeral-container-notes -n kube-system -o yaml | sed -n '1,35p'
kubectl get pod ephemeral-lesson-target -o jsonpath='{.spec.containers[*].name}{"\n"}' 2>/dev/null || true
```

## Troubleshooting

- **`Forbidden` debug** → RBAC needs `pods/ephemeralcontainers` **patch** permission
- **`shareProcessNamespace` false and you need peer PIDs** → Pod must be recreated with **`spec.shareProcessNamespace: true`** (cannot retroactively enable in all cases)
- **Wrong `--target`** → must be an **existing container name** in the Pod
- **Minimal image missing `sh`** → use **`busybox`** or **`debug` distro image**
- **Cannot “delete” ephemeral container** → delete Pod or replace workload; document behavior for stakeholders
- **Ephemeral stuck `ContainerCreating`** → node or registry issues; `describe pod` Events

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/ephemeral-container-notes.yaml` | In-cluster notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Admission and debug workflow drills |

## Cleanup

```bash
kubectl delete pod ephemeral-lesson-target --ignore-not-found 2>/dev/null || true
kubectl delete configmap ephemeral-container-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.1.5 Disruptions](../2.4.1.5-disruptions/README.md)
