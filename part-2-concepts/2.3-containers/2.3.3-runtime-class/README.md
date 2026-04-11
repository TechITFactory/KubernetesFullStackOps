# 2.3.3 Runtime Class — teaching transcript

## Intro

**RuntimeClass** is a cluster-level object that maps a **name** you put on a Pod (`runtimeClassName`) to a **handler** string the node’s container runtime understands. That handler might select **runc** (default Linux OCI runtime), or a sandboxed stack such as **gVisor** (`runsc`) or **Kata Containers** (VM-backed isolation), depending on what was installed and registered on the node. If you **omit** `runtimeClassName`, the pod uses the runtime’s **default handler** — there is nothing wrong with that; most clusters never set RuntimeClass at all. Scheduling a pod with a handler the node cannot satisfy produces **Failed** or **Pending** events you diagnose by comparing **RuntimeClass.spec.handler** to what containerd or CRI-O actually exposes (often visible in config on the node or via runtime docs).

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** This lesson creates a **cluster-scoped** `RuntimeClass` object. **Scheduling a Pod** with `runtimeClassName: sandboxed-runtime` only works if nodes advertise that handler — many labs have no such runtime; treat apply here as **API learning**, not guaranteed pod success.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-2-concepts/2.3-containers/2.3.3-runtime-class"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  apply RuntimeClass (name → handler)  →  get / describe API object
                        │
                        ▼
              (optional) compare to node runtime config / labels
```

**Say:**

We register a RuntimeClass in the API so you see the shape of the object; whether pods can use it depends on whether your nodes’ runtimes actually implement handler `sandboxed`.

---

## Step 1 — Create the RuntimeClass object

**What happens when you run this:**

`kubectl apply -f yamls/runtimeclass-demo.yaml` creates cluster-scoped `RuntimeClass` `sandboxed-runtime` with `handler: sandboxed`. Handlers are opaque strings to Kubernetes — the **runtime** interprets them.

**Say:**

In production, `sandboxed` might map to gVisor or Kata in containerd’s config; here we only teach the API contract. With **no** `runtimeClassName` on a pod, kubelet uses the default runtime path (typically **runc** under containerd/CRI-O).

**Run:**

```bash
cd "$COURSE_DIR/part-2-concepts/2.3-containers/2.3.3-runtime-class"
kubectl apply -f yamls/runtimeclass-demo.yaml
```

**Expected:**

`runtimeclass.node.k8s.io/sandboxed-runtime created` or unchanged.

---

## Step 2 — List RuntimeClass objects

**What happens when you run this:**

`kubectl get runtimeclass` lists cluster-scoped RuntimeClass resources — read-only.

**Say:**

This is how you discover what names developers can place in `spec.runtimeClassName`. Empty output on a minimal cluster is normal before this lesson’s apply.

**Run:**

```bash
kubectl get runtimeclass
```

**Expected:**

Row for `sandboxed-runtime` with `HANDLER` column showing `sandboxed` (exact columns depend on kubectl version).

---

## Step 3 — Describe the RuntimeClass

**What happens when you run this:**

`kubectl describe` prints spec details and events if any — read-only.

**Say:**

I confirm handler spelling matches what ops configured in **containerd** (`[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.*]`) or **CRI-O** (`crio.runtime.runtimes`); a typo here means pods never start with that class.

**Run:**

```bash
kubectl describe runtimeclass sandboxed-runtime
```

**Expected:**

`Handler: sandboxed` (or equivalent) in the description output.

---

## Step 4 — Relate handlers to nodes (read-only cluster view)

**What happens when you run this:**

`kubectl get nodes -o wide` shows schedulable capacity — read-only. Full handler discovery is **node-local**: on a Linux node you inspect runtime config or use vendor docs; the API does not always list every OCI handler in one place.

**Say:**

If I needed to prove which handlers exist, I would SSH to a node and read containerd or CRI-O config, or consult the platform guide for GKE Sandbox / AKS gVisor. From kubectl alone I sanity-check that nodes exist to run future pods that reference this RuntimeClass.

**Run:**

```bash
kubectl get nodes -o wide
```

**Expected:**

At least one node on a healthy lab cluster.

---

## Troubleshooting

- **`FailedScheduling` with RuntimeClass-related message** → handler not configured on any node runtime; fix node config or remove `runtimeClassName` from the pod
- **Pod `RunContainerError` after schedule** → handler name mismatch between RuntimeClass and runtime registration
- **No `RuntimeClass` resource type** → cluster version or feature gate; upgrade or enable APIs per your distribution
- **Expecting gVisor/Kata but only runc works** → install and register the alternate runtime on nodes before referencing it in RuntimeClass
- **Omitting `runtimeClassName` and “wrong” isolation** → default handler is intentional; add RuntimeClass only when policy requires sandboxing
- **`Forbidden` creating RuntimeClass** → need cluster-scoped create RBAC

---

## Learning objective

- Created a **RuntimeClass** and read back **handler** through get and describe.
- Explained that **no** `runtimeClassName` means the runtime **default** (typically runc-class behavior).
- Described how to validate **available handlers** on real nodes (runtime config on the node, not only kubectl).

## Why this matters

Security and compliance teams ask for sandboxed workloads; RuntimeClass is the knob, but the handler must exist on the node or pods fail in confusing ways.

## Video close — fast validation

**What happens when you run this:**

RuntimeClass wide listing and nodes wide — read-only.

**Say:**

I pair the class list with nodes so the audience remembers scheduling still needs a capable node behind the handler name.

**Run:**

```bash
kubectl get runtimeclass -o wide
kubectl get nodes -o wide
```

**Expected:**

`sandboxed-runtime` visible; node list present.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/runtimeclass-demo.yaml` | RuntimeClass manifest |
| `yamls/failure-troubleshooting.yaml` | Handler mismatch / scheduling |

---

## Cleanup

**What happens when you run this:**

Deletes the demo RuntimeClass. `--ignore-not-found` and `|| true` keep cleanup idempotent.

**Say:**

I remove the demo class so the cluster returns to its prior RuntimeClass set.

**Run:**

```bash
kubectl delete runtimeclass sandboxed-runtime --ignore-not-found 2>/dev/null || true
```

**Expected:**

RuntimeClass removed or delete no-op.

---

## Next

[2.3.4 Container lifecycle hooks](../2.3.4-container-lifecycle-hooks/README.md)
