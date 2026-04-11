# 2.7.4 Resource Management for Pods and Containers — teaching transcript

## Intro

**resources.requests** declare what the **scheduler** must find on a node (**CPU** and **memory** are the common pair; extended resources like **GPU** use the same block). **resources.limits** cap usage: **CPU** is **compressible** (throttling); **memory** is **incompressible** (**OOMKill**). **LimitRange** can default requests/limits per namespace; **ResourceQuota** caps namespace totals ([2.4.2.1](../../04-workloads/14-pod-group-policies/README.md) if present). **QoS class** ([2.4 workloads QoS](../../04-workloads/08-pod-quality-of-service-classes/README.md)) derives from how you set requests and limits across containers.

**Prerequisites:** [2.7.3 Probes](../03-liveness-readiness-and-startup-probes/README.md).

## Flow of this lesson

```
  Pod spec: requests + limits per container
              │
              ├── scheduler filters nodes (requests)
              ├── cgroup limits on node (limits)
              └── QoS + eviction ordering
```

**Say:**

**No requests** means **BestEffort** and first to evict—fine for throwaway jobs, risky for revenue services.

## Learning objective

- Contrast **requests** (scheduling) and **limits** (enforcement).
- Explain **CPU throttle** vs **memory OOM** behavior.
- Read **`kubectl describe pod`** for **Limits** and **Requests** lines.

## Why this matters

HPA and cluster autoscalers use **requests** as denominators for utilization—wrong requests break scaling math.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/07-configuration/04-resource-management-for-pods-and-containers" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Resource management teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-7-4-resource-management-for-pods-and-containers-notes.yaml
kubectl get cm -n kube-system 2-7-4-resource-management-for-pods-and-containers-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-7-4-resource-management-for-pods-and-containers-notes` when RBAC allows.

---

## Step 2 — Sample live Pod resource stanzas (read-only)

**What happens when you run this:**

**jsonpath** prints requests/limits for first container of each listed pod—noisy on huge clusters.

**Say:**

I pick **one** known namespace in production; here we skim **default** or **kube-system** lightly.

**Run:**

```bash
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{"\t"}{.spec.containers[0].resources}{"\n"}{end}' 2>/dev/null | head -n 15 || true
```

**Expected:** Map snippets or empty `{}` for unset resources.

---

## Step 3 — Explain resources field (read-only)

**What happens when you run this:**

Official field documentation.

**Run:**

```bash
kubectl explain pod.spec.containers.resources 2>/dev/null | head -n 35 || true
```

**Expected:** **requests**, **limits**, **claims** (when relevant) documented.

## Video close — fast validation

```bash
kubectl top pods -A 2>/dev/null | head -n 15 || true
kubectl describe nodes 2>/dev/null | sed -n '/Allocated resources:/,/Events:/p' | head -n 25 || true
```

## Troubleshooting

- **OOMKilled** → raise **memory limit** or fix leak; check **WSS** vs **limit**
- **CPU throttle** → **CFS quota**—raise limit or reduce work; **requests** affect **shares** on some paths
- **Pending for resources** → **Insufficient cpu/memory** in events—node too small or **fragmentation**
- **HPA weird percentages** → **requests** missing on Pod template
- **LimitRange injects surprises** → `kubectl get limitrange -n ...`

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-7-4-resource-management-for-pods-and-containers-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-7-4-resource-management-for-pods-and-containers-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.7.5 Organizing Cluster Access Using kubeconfig Files](../05-organizing-cluster-access-using-kubeconfig-files/README.md)
