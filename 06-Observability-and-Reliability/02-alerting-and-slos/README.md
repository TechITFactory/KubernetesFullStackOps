# Alerting and SLOs — teaching transcript

## Intro

**Alerts** **encode** **symptoms** **(PromQL** **or** **vendor** **query)** **plus** **timing** **gates** **`for:`** **so** **brief** **spikes** **do** **not** **page** **on-call**. **SLOs** **tie** **those** **symptoms** **to** **user-visible** **reliability** **budgets**. **The** **sample** **`PrometheusRule`** **declares** **`HighCPUUsage`** **with** **`for: 5m`** **over** **a** **placeholder** **expression** **—** **tune** **`expr`** **to** **your** **metric** **names** **before** **production** **use**.

**Prerequisites:** [6.1 Metrics, logs, and traces](../01-metrics-logs-traces/README.md); **Prometheus** **Operator** **(optional** **for** **`kubectl apply`)**.

## Flow of this lesson

```
  Prometheus evaluates recording + alert rules on interval
              │
              ▼
  Alert transitions Pending → Firing after `for` duration
              │
              ▼
  Alertmanager routes to PagerDuty / Slack / etc.
```

**Say:**

**The** **`for: 5m` line** **is** **the** **difference** **between** **SRE** **and** **noise** **factory**.

## Learning objective

- **Read** **`PrometheusRule`** **YAML** **and** **identify** **`alert`**, **`expr`**, **`for`**, **and** **`annotations`**.
- **Explain** **why** **alert** **queries** **should** **target** **symptoms**, **not** **causes** **(CPU** **is** **a** **symptom** **example** **here)**.

## Why this matters

**Pager** **fatigue** **kills** **response** **quality** **—** **time** **gates** **and** **SLOs** **protect** **humans**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/06-Observability-and-Reliability/02-alerting-and-slos" 2>/dev/null || cd .
```

## Step 1 — Inspect the PrometheusRule

**What happens when you run this:**

**You** **study** **`high-cpu-alert`**: **group** **`general-alerts`**, **rule** **`HighCPUUsage`**, **`expr`** **summing** **container** **CPU** **rates**, **`for: 5m`**, **annotations**.

**Run:**

```bash
cat yamls/alert-rule.yaml
```

**Expected:** **`kind: PrometheusRule`**, **`alert:`**, **`expr:`**, **`for: 5m`**.

---

## Step 2 — Optional apply

**What happens when you run this:**

**Registers** **the** **rule** **in** **clusters** **with** **the** **CRD** **installed**.

**Run:**

```bash
kubectl apply -f yamls/alert-rule.yaml 2>/dev/null || echo "Skip: PrometheusRule CRD not installed"
```

**Expected:** **Created** **or** **skip** **message**.

## Video close — fast validation

**What happens when you run this:**

**Deletes** **the** **rule** **if** **applied**.

**Run:**

```bash
kubectl delete -f yamls/alert-rule.yaml --ignore-not-found 2>/dev/null || true
```

**Expected:** **Rule** **removed**.

## Troubleshooting

- **`expr` references** **missing** **metrics** → **rule** **never** **fires** **or** **errors** **in** **Prometheus** **UI**
- **Wrong** **`namespace=` label** **in** **`expr`** → **edit** **to** **match** **your** **workloads**
- **No** **`PrometheusRule` CRD** → **install** **Prometheus** **Operator** **stack**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/alert-rule.yaml` | **`PrometheusRule`** **with** **`HighCPUUsage`** |

## Cleanup

```bash
kubectl delete -f yamls/alert-rule.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[6.3 Autoscaling decisions](../03-autoscaling-decisions/README.md)
