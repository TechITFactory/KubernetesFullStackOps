# Metrics, logs, and traces — teaching transcript

## Intro

**Operators** **live** **in** **three** **telemetry** **streams:** **metrics** **(counters**, **histograms**, **gauges)**, **logs** **(structured** **or** **line-oriented)**, **and** **traces** **(distributed** **request** **paths)**. **On** **Kubernetes**, **Prometheus-style** **scraping** **often** **uses** **`ServiceMonitor`** **objects** **from** **the** **[Prometheus** **Operator](https://github.com/prometheus-operator/prometheus-operator)** **to** **discover** **targets**. **This** **lesson** **runs** **a** **tiny** **local** **log** **script** **and** **reads** **`service-monitor.yaml`** **—** **no** **cluster** **apply** **is** **required** **for** **the** **ServiceMonitor** **unless** **you** **have** **the** **CRD**.

**Prerequisites:** [Track 6 module](../README.md); [Track 2: Core workloads](../../02-Core-Workloads/README.md) **(Services** **and** **labels**, **optional)**.

## Flow of this lesson

```
  App emits logs to stdout + /metrics (typical)
              │
              ▼
  Collectors scrape / ship to backends
              │
              ▼
  ServiceMonitor wires Prometheus to labeled Services
```

**Say:**

**If** **your** **`Service` lacks** **`port` name** **`web`**, **the** **sample** **`ServiceMonitor` needs** **editing** **to** **match** **your** **chart**.

## Learning objective

- **Run** **`scripts/generate-logs.sh`** **and** **relate** **output** **to** **what** **aggregators** **ingest**.
- **Read** **`ServiceMonitor`** **YAML** **and** **explain** **`selector`**, **`endpoints.path`**, **and** **`interval`**.

## Why this matters

**Without** **metrics** **and** **logs**, **you** **only** **know** **“the** **site** **is** **down”** **—** **not** **which** **Pod** **or** **which** **dependency** **failed**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/06-Observability-and-Reliability/01-metrics-logs-traces" 2>/dev/null || cd .
```

## Step 1 — Generate mock application logs

**What happens when you run this:**

**A** **bash** **loop** **prints** **success** **lines** **then** **an** **error** **with** **a** **fake** **`TraceID`**.

**Say:**

**Real** **apps** **should** **emit** **structured** **JSON** **—** **this** **script** **is** **only** **a** **teaching** **stand-in**.

**Run:**

```bash
bash scripts/generate-logs.sh
```

**Expected:** **Five** **`[INFO]`** **lines**, **then** **`[ERROR] Database timeout`** **with** **`TraceID`**.

---

## Step 2 — Inspect the ServiceMonitor

**What happens when you run this:**

**You** **read** **`monitoring.coreos.com/v1` `ServiceMonitor`** **that** **selects** **`app: frontend`**, **scrapes** **`/metrics`**, **`interval: 15s`**, **port** **`web`**.

**Run:**

```bash
cat yamls/service-monitor.yaml
```

**Expected:** **`kind: ServiceMonitor`**, **`selector.matchLabels.app: frontend`**, **`endpoints`**.

---

## Step 3 — Optional apply (Prometheus Operator required)

**What happens when you run this:**

**Creates** **`frontend-monitor`** **only** **if** **the** **CRD** **exists**.

**Run:**

```bash
kubectl apply -f yamls/service-monitor.yaml 2>/dev/null || echo "Skip apply: ServiceMonitor CRD not installed"
```

**Expected:** **Created** **or** **skip** **message**.

## Video close — fast validation

**What happens when you run this:**

**Deletes** **the** **ServiceMonitor** **if** **you** **applied** **it**.

**Run:**

```bash
kubectl delete -f yamls/service-monitor.yaml --ignore-not-found 2>/dev/null || true
```

**Expected:** **Resource** **absent**.

## Troubleshooting

- **`bash` not** **found** **on** **Windows** → **Git** **Bash**, **WSL**, **or** **run** **commands** **manually**
- **`ServiceMonitor` apply** **fails** → **install** **Prometheus** **Operator** **CRDs** **first**
- **No** **scrapes** **in** **UI** → **Service** **labels**, **TLS**, **and** **`port` names** **must** **line** **up**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/generate-logs.sh` | **Mock** **stdout** **log** **stream** |
| `yamls/service-monitor.yaml` | **Prometheus** **Operator** **`ServiceMonitor`** |

## Cleanup

```bash
kubectl delete -f yamls/service-monitor.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[6.2 Alerting and SLOs](../02-alerting-and-slos/README.md)
