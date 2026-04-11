# 2.11.16 API Priority and Fairness — teaching transcript

## Intro

**API** **Priority** **and** **Fairness** **(APF)** **protects** **the** **apiserver** **from** **overload** **by** **classifying** **requests** **into** **flows** **and** **queues** **with** **limits** **and** **borrow/lend** **semantics**. **Misconfiguration** **can** **starve** **controllers** **or** **let** **noisy** **tenants** **saturate** **shared** **queues**. **Objects** **like** **`FlowSchema`** **and** **`PriorityLevelConfiguration`** **live** **in** **`flowcontrol.apiserver.k8s.io`**.

**Prerequisites:** [2.11.15 Proxies in Kubernetes](../15-proxies-in-kubernetes/README.md).

## Flow of this lesson

```
  Request classified by FlowSchema
              │
              ▼
  Assigned to PriorityLevelConfiguration queue
              │
              ▼
  Apiserver admits or rejects with 429-equivalent behavior
```

**Say:**

**When** **users** **see** **throttling** **without** **hitting** **etcd**, **I** **check** **APF** **before** **blaming** **the** **network**.

## Learning objective

- List **`FlowSchema`** **and** **`PriorityLevelConfiguration`** **objects** **when** **the** **API** **group** **is** **available**.
- Explain **why** **APF** **complements** **client-side** **rate** **limits**.

## Why this matters

**Large** **clusters** **with** **chatty** **operators** **need** **fair** **queuing** **or** **everyone** **loses** **when** **one** **job** **misbehaves**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/16-api-priority-and-fairness" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-16-api-priority-and-fairness-notes.yaml
kubectl get cm -n kube-system 2-11-16-api-priority-and-fairness-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-16-api-priority-and-fairness-notes`** when allowed.

---

## Step 2 — APF objects (read-only)

**What happens when you run this:**

**Fails** **gracefully** **on** **clusters** **without** **the** **group** **or** **with** **RBAC** **deny**.

**Run:**

```bash
kubectl get flowschema 2>/dev/null | head -n 15 || true
kubectl get prioritylevelconfiguration 2>/dev/null | head -n 15 || true
```

**Expected:** **Tables** **or** **errors** **(expected** **on** **some** **environments)**.

## Video close — fast validation

```bash
kubectl api-resources --api-group=flowcontrol.apiserver.k8s.io 2>/dev/null || true
```

## Troubleshooting

- **429** **from** **apiserver** → **APF**, **etcd**, **or** **webhook** **latency**—**triangulate**
- **Cannot** **list** **APF** **objects** → **managed** **control** **plane** **hides** **them**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-16-api-priority-and-fairness-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-11-16-api-priority-and-fairness-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.17 Installing addons](../17-installing-addons/README.md)
