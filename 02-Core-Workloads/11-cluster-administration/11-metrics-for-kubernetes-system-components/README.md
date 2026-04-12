# Metrics for Kubernetes system components — teaching transcript

## Intro

**Control** **plane** **and** **node** **components** **expose** **Prometheus** **metrics** **on** **HTTP** **endpoints** **(often** **behind** **authentication** **or** **network** **policy)**. **Admins** **scrape** **apiserver**, **scheduler**, **controller-manager**, **etcd**, **kubelet**, **and** **kube-proxy** **to** **watch** **request** **rates**, **queue** **depths**, **and** **saturation**. **Managed** **clusters** **may** **surface** **these** **only** **via** **cloud** **monitoring** **integrations**.

**Prerequisites:** [2.11.10 Compatibility version for Kubernetes control plane components](../10-compatibility-version-for-kubernetes-control-plane-components/README.md).

## Flow of this lesson

```
  Component /metrics endpoint
              │
              ▼
  Prometheus or vendor scraper
              │
              ▼
  Dashboards and alerts (SLOs)
```

**Say:**

**Apiserver** **`apiserver_request_total`** **is** **my** **first** **graph** **when** **users** **report** **slow** **`kubectl`**.

## Learning objective

- List **`APIService`** **rows** **related** **to** **metrics** **when** **present**.
- Name **which** **components** **typically** **emit** **Prometheus** **metrics**.

## Why this matters

**Without** **component** **metrics**, **you** **debug** **control** **plane** **incidents** **with** **guesswork**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/11-metrics-for-kubernetes-system-components" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-11-metrics-for-kubernetes-system-components-notes.yaml
kubectl get cm -n kube-system 2-11-11-metrics-for-kubernetes-system-components-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-11-metrics-for-kubernetes-system-components-notes`** when allowed.

---

## Step 2 — Metrics API aggregation hints (read-only)

**What happens when you run this:**

**Shows** **whether** **metrics.k8s.io** **or** **custom** **metrics** **APIs** **are** **registered**.

**Run:**

```bash
kubectl get apiservice 2>/dev/null | grep -i metrics | head -n 15 || true
kubectl top nodes 2>/dev/null | head -n 8 || true
```

**Expected:** **APIService** **lines**; **`top`** **if** **metrics-server** **works**.

## Video close — fast validation

```bash
kubectl get --raw /metrics 2>/dev/null | head -n 5 || true
```

## Troubleshooting

- **`--raw /metrics` forbidden** → **RBAC** **or** **disabled** **endpoint**
- **No** **metrics** **APIService** → **install** **metrics-server** **or** **vendor** **adapter**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-11-metrics-for-kubernetes-system-components-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-11-11-metrics-for-kubernetes-system-components-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.12 Metrics for Kubernetes object states](../12-metrics-for-kubernetes-object-states/README.md)
