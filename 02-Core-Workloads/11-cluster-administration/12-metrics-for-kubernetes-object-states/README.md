# 2.11.12 Metrics for Kubernetes object states — teaching transcript

## Intro

**Beyond** **node** **CPU**/**memory**, **Kubernetes** **ecosystem** **exposes** **workload** **metrics**: **kube-state-metrics** **turns** **object** **API** **state** **into** **time** **series** **(Deployments**, **replica** **counts**, **Pod** **phases)**, **enabling** **alerts** **on** **stuck** **rollouts**. **Horizontal** **Pod** **Autoscaler** **may** **consume** **custom** **or** **external** **metrics** **via** **metrics** **APIs**. **Admins** **wire** **RBAC** **for** **scrapers** **and** **protect** **cardinality**.

**Prerequisites:** [2.11.11 Metrics for Kubernetes system components](../11-metrics-for-kubernetes-system-components/README.md).

## Flow of this lesson

```
  API object state (desired vs current)
              │
              ▼
  kube-state-metrics or equivalent exporter
              │
              ▼
  Alerts on drift (available != desired, crash loops)
```

**Say:**

**I** **alert** **on** **`kube_deployment_spec_replicas`** **versus** **`kube_deployment_status_replicas_available`**—**that** **catches** **silent** **failed** **rollouts**.

## Learning objective

- Explain **why** **object** **state** **metrics** **complement** **container** **`top`**.
- Inspect **Deployment** **status** **fields** **with** **`kubectl`** **as** **the** **source** **of** **truth**.

## Why this matters

**Pods** **look** **“Running”** **while** **readiness** **never** **passes**—**object** **metrics** **expose** **that** **pattern** **fast**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/12-metrics-for-kubernetes-object-states" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-12-metrics-for-kubernetes-object-states-notes.yaml
kubectl get cm -n kube-system 2-11-12-metrics-for-kubernetes-object-states-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-12-metrics-for-kubernetes-object-states-notes`** when allowed.

---

## Step 2 — Deployment status vs spec (read-only)

**What happens when you run this:**

**First** **Deployment** **in** **cluster** **shows** **replica** **fields** **metrics** **would** **mirror**.

**Run:**

```bash
NS="$(kubectl get deploy -A -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null)"
NM="$(kubectl get deploy -A -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [ -n "$NS" ] && [ -n "$NM" ]; then kubectl get deploy "$NM" -n "$NS" -o jsonpath='specReplicas={.spec.replicas} replicas={.status.replicas} ready={.status.readyReplicas} available={.status.availableReplicas}{"\n"}' 2>/dev/null; fi || true
kubectl get deploy -A 2>/dev/null | head -n 12 || true
```

**Expected:** **Numeric** **replica** **line** **or** **empty**; **table** **header** **and** **rows**.

## Video close — fast validation

```bash
kubectl explain deployment.status 2>/dev/null | head -n 25 || true
```

## Troubleshooting

- **No** **Deployments** → **use** **StatefulSet** **or** **DaemonSet** **instead**
- **Cardinality** **explosion** → **label** **drops** **in** **Prometheus** **relabelling**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-12-metrics-for-kubernetes-object-states-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-11-12-metrics-for-kubernetes-object-states-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.13 System logs](../13-system-logs/README.md)
