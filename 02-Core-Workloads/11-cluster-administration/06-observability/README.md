# 2.11.6 Observability — teaching transcript

## Intro

**Observability** **on** **Kubernetes** **usually** **means** **three** **pillars** **wired** **through** **DaemonSets** **and** **scrapers**: **metrics** **(Prometheus-style)**, **logs** **(node** **or** **cluster** **aggregators)**, **and** **traces** **(OpenTelemetry)**. **Cluster** **admins** **care** **about** **who** **collects** **what**, **retention**, **RBAC** **to** **data**, **and** **cost** **at** **ingest**. **This** **lesson** **frames** **the** **plumbing**; **later** **2.11.x** **lessons** **deepen** **logs**, **metrics**, **and** **traces**.

**Prerequisites:** [2.11.5 Cluster networking](../05-cluster-networking/README.md).

## Flow of this lesson

```
  Telemetry emitters (kubelet, apiserver, workloads)
              │
              ▼
  Collection agents (DaemonSet, sidecar, remote write)
              │
              ▼
  Storage + dashboards + alerts
```

**Say:**

**I** **draw** **one** **request** **path** **through** **Ingress**, **Service**, **Pod**, **and** **where** **a** **span** **would** **attach**—**then** **metrics** **and** **logs** **fall** **naturally** **on** **the** **diagram**.

## Learning objective

- List **namespaces** **and** **kube-system** **pods** **that** **hint** **at** **installed** **observability** **stack**.
- Separate **platform** **metrics** **from** **application** **telemetry** **ownership**.

## Why this matters

**Blind** **clusters** **mean** **PagerDuty** **fires** **only** **after** **customers** **notice**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/06-observability" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-6-observability-notes.yaml
kubectl get cm -n kube-system 2-11-6-observability-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-6-observability-notes`** when allowed.

---

## Step 2 — Namespace inventory and observability hints (read-only)

**What happens when you run this:**

**Script** **lists** **namespaces**; **grep** **finds** **common** **vendor** **DaemonSets**.

**Run:**

```bash
bash scripts/inspect-2-11-6-observability.sh 2>/dev/null || true
kubectl get pods -A 2>/dev/null | grep -iE 'prometheus|grafana|loki|otel|jaeger|datadog|newrelic|fluent' | head -n 20 || true
```

**Expected:** **Namespace** **list**; **optional** **telemetry** **pod** **names**.

## Video close — fast validation

```bash
kubectl get apiservice 2>/dev/null | grep -i metrics | head -n 10 || true
```

## Troubleshooting

- **No** **metrics** **API** → **metrics-server** **or** **vendor** **adapter** **missing**
- **Log** **duplication** → **node** **agent** **plus** **sidecar** **misconfig**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-6-observability-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-11-6-observability.sh` | **`kubectl get ns`** |

## Cleanup

```bash
kubectl delete configmap 2-11-6-observability-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.7 Admission webhook good practices](../07-admission-webhook-good-practices/README.md)
