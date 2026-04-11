# 2.4.3.4 DaemonSet — teaching transcript

## Intro

A **DaemonSet** runs **one pod per eligible node** (matching **nodeSelector**, **affinity**, and **tolerations**), not a fixed **`replicas:`** count like a Deployment. **Platform agents**—log collectors, **node exporters**, **CNI** helpers, even **kube-proxy** historically—are classic DaemonSets. **Control-plane nodes** are often **tainted**; DaemonSets that must run there need explicit **tolerations**. **`updateStrategy`** is **`RollingUpdate`** (default on supported versions) or **`OnDelete`** (replace pods only when node deletes pod or you delete manually)—choose based on how tightly you must control blast radius during upgrades.

**Prerequisites:** [2.4.3.3 StatefulSet](../2.4.3.3-statefulsets/README.md).

## Learning objective

- Explain **one pod per schedulable node** vs replica count.
- Name **node agent** use cases and **toleration** needs for control-plane nodes.
- Use **`kubectl rollout status`** and DaemonSet **status counters**.

## Why this matters

Platform teams ship many add-ons as DaemonSets. When a node taints or goes **NotReady**, DaemonSet pods are often the first signal that the node is unhealthy for workloads.

## Flow of this lesson

```
  DaemonSet
      │
      ├── Node A → Pod
      ├── Node B → Pod
      └── Node C → Pod   (if schedulable + matches policy)
```

**Say:**

On **Minikube**, expect **one** pod—**desiredNumberScheduled** follows your node list, not your gut.

## Concepts (short theory)

- **maxUnavailable** / **maxSurge** for DaemonSet rolling updates depend on API version—consult `kubectl explain daemonset.spec.updateStrategy`.

---

## Step 1 — Apply DaemonSet and wait

**What happens when you run this:**

**busybox** sleep pod on **each node** that accepts the pod; single-node labs show **one** pod.

**Say:**

I compare **`kubectl get ds`** **DESIRED** to **`kubectl get nodes`** count.

**Run:**

```bash
kubectl apply -f yamls/daemonset-demo.yaml
kubectl rollout status daemonset/daemonset-demo --timeout=180s
kubectl get pods -l app=daemonset-demo -o wide
```

**Expected:** Pod count equals **schedulable** nodes matching policy (often 1 locally).

---

## Step 2 — Verify script

**What happens when you run this:**

Asserts **desired**, **current**, and **ready** match—portable across cluster sizes.

**Run:**

```bash
chmod +x scripts/verify-daemonset-lesson.sh
./scripts/verify-daemonset-lesson.sh
```

**Expected:** Script succeeds.

## Troubleshooting

- **Fewer pods than nodes** → **taints/tolerations**, **nodeSelector**, or **Pod topology** constraints
- **DaemonSet not updating** → **`OnDelete`** strategy—delete pods to pick up new template
- **CrashLoop on every node** → bad **hostPath** or **privilege**—affects whole fleet instantly
- **Control-plane missing agent** → add **tolerations** for **control-plane** / **master** taints
- **Rollout stuck** → describe DaemonSet; check **maxUnavailable** and pod **Events**
- **Verify script “wrong count”** → reread script—it compares **counters**, not “must be 3”

## Video close — fast validation

**Say:**

I show **nodes** beside **pods** so the “one per node” story clicks.

```bash
kubectl get ds daemonset-demo
kubectl get pods -l app=daemonset-demo -o wide
kubectl get nodes -o wide
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/daemonset-demo.yaml` | Minimal DaemonSet (busybox sleep) |
| `yamls/failure-troubleshooting.yaml` | Taints, selectors, placement |
| `scripts/verify-daemonset-lesson.sh` | Rollout + desired/current/ready equality |

## Cleanup

```bash
kubectl delete -f yamls/daemonset-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.3.5 Jobs](../2.4.3.5-jobs/README.md)
