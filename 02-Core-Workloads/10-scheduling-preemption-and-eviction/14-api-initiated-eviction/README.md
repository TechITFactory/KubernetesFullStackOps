# 2.10.14 API-initiated Eviction — teaching transcript

## Intro

**API-initiated** **eviction** **uses** **the** **`POST .../pods/.../evictions`** **subresource** **(via** **`kubectl drain`**, **`kubectl evict`**, **controllers**, **or** **HTTP** **clients)** **so** **the** **API** **server** **can** **enforce** **PodDisruptionBudgets** **and** **grace** **periods** **before** **removing** **Pods**. **This** **differs** **from** **kubelet** **pressure** **eviction** **(lesson** **2.10.13)** **and** **from** **scheduler** **preemption** **(lesson** **2.10.12)**. **Draining** **nodes** **for** **upgrades** **is** **the** **everyday** **face** **of** **API** **eviction**.

**Prerequisites:** [2.10.13 Node-pressure Eviction](../13-node-pressure-eviction/README.md).

## Flow of this lesson

```
  Client requests eviction subresource
              │
              ▼
  API checks PDB minAvailable / maxUnavailable
              │
              ▼
  Pod deleted with grace; or 429 Too Many Requests / blocked
```

**Say:**

**When** **`kubectl drain` hangs**, **I** **open** **PDBs** **in** **the** **namespace** **before** **blaming** **the** **node**.

## Learning objective

- Use **`kubectl explain`** **for** **`poddisruptionbudget.spec`** **and** **relate** **it** **to** **voluntary** **disruptions**.
- Contrast **API** **eviction** **with** **kubelet** **eviction** **and** **preemption**.

## Why this matters

**PDB** **misconfiguration** **blocks** **node** **repairs** **or** **allows** **full** **service** **outages** **during** **drains**—**both** **hurt** **SLOs**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/14-api-initiated-eviction" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-14-api-initiated-eviction-notes.yaml
kubectl get cm -n kube-system 2-10-14-api-initiated-eviction-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-14-api-initiated-eviction-notes`** when allowed.

---

## Step 2 — List PodDisruptionBudgets and explain spec (read-only)

**What happens when you run this:**

**Shows** **whether** **teams** **defined** **disruption** **guardrails**; **`explain`** **covers** **`minAvailable`** **and** **`maxUnavailable`**.

**Run:**

```bash
kubectl get pdb -A 2>/dev/null | head -n 20 || true
kubectl explain poddisruptionbudget.spec 2>/dev/null | head -n 35 || true
```

**Expected:** **PDB** **table** **(may** **be** **empty)**; **spec** **documentation**.

## Video close — fast validation

```bash
kubectl explain poddisruptionbudget.status 2>/dev/null | head -n 20 || true
```

## Troubleshooting

- **Drains** **ignore** **PDB** **with** **`--force`** → **dangerous**—**call** **out** **in** **runbooks**
- **PDB** **selects** **too** **many** **Pods** → **tighten** **matchLabels**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-14-api-initiated-eviction-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-10-14-api-initiated-eviction-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.15 Node Declared Features](../15-node-declared-features/README.md)
