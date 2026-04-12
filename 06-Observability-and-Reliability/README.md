# Track 6: Observability and reliability — teaching transcript

## Intro

**Observability** **(metrics**, **logs**, **traces)** **tells** **you** **what** **broke** **and** **how** **fast**. **Alerting** **and** **SLOs** **decide** **who** **wakes** **up** **and** **when** **;** **autoscaling** **ties** **signals** **to** **capacity** **;** **backup** **and** **DR** **protect** **state** **and** **API** **objects** **;** **incident** **handling** **is** **the** **muscle** **memory** **of** **`kubectl describe`** **and** **events**. **This** **track** **mixes** **read-only** **YAML** **study** **with** **small** **cluster** **exercises** **where** **manifests** **exist** **in** **the** **repo**.

**Prerequisites:** [Track 5: Security and policy](../05-Security-and-Policy/README.md); [Track 2: Core workloads](../../02-Core-Workloads/README.md) **(Deployments**, **Services**, **HPA** **concepts)**; **optional:** **[Prometheus** **Operator](https://github.com/prometheus-operator/prometheus-operator)** **CRDs** **for** **6.1–6.2** **samples**; **metrics-server** **for** **6.3** **HPA** **labs**.

## Flow of this lesson

```
  6.1 Metrics / logs / traces (ServiceMonitor + log script)
              │
              ▼
  6.2 Alerting and SLOs (PrometheusRule)
              │
              ▼
  6.3 Autoscaling (stress Deployment + HPA)
              │
              ▼
  6.4 Backup and DR (Velero CRs, read-first)
              │
              ▼
  6.5 Incident handling (broken Pod + describe)
```

**Say:**

**I** **teach** **`kubectl get events`** **and** **`describe`** **before** **fancy** **dashboards** **—** **they** **work** **in** **every** **cluster** **everywhere**.

## Learning objective

- **Interpret** **`ServiceMonitor`** **and** **`PrometheusRule`** **YAML** **when** **the** **Prometheus** **Operator** **is** **present**.
- **Run** **the** **HPA** **lab** **and** **explain** **why** **metrics-server** **matters**.
- **Use** **`kubectl describe`** **to** **close** **an** **`ImagePullBackOff`** **story**.

## Why this matters

**Reliability** **is** **not** **nine** **nines** **of** **uptime** **alone** **—** **it** **is** **detect**, **diagnose**, **mitigate**, **and** **learn** **under** **pressure**.

## Children (suggested order)

1. [6.1 Metrics, logs, and traces](01-metrics-logs-traces/README.md)
2. [6.2 Alerting and SLOs](02-alerting-and-slos/README.md)
3. [6.3 Autoscaling decisions](03-autoscaling-decisions/README.md)
4. [6.4 Backup and DR](04-backup-and-dr/README.md)
5. [6.5 Incident handling](05-incident-handling/README.md)

## Module wrap — quick validation

**What happens when you run this:** **Quick** **signal** **whether** **metrics** **API** **and** **HPA** **can** **work** **in** **your** **lab**.

**Say:**

**If** **`kubectl top nodes` fails**, **fix** **metrics-server** **before** **recording** **6.3**.

```bash
kubectl top nodes 2>/dev/null | head -n 5 || echo "metrics-server likely missing or RBAC denied"
kubectl api-resources 2>/dev/null | grep -i servicemonitor | head -n 3 || true
```

## Troubleshooting

- **Prometheus** **CRDs** **missing** → **6.1–6.2** **are** **read-only** **unless** **you** **install** **the** **operator**
- **HPA** **`unknown`** **targets** → **install** **[metrics-server](https://github.com/kubernetes-sigs/metrics-server)**
- **Velero** **CRDs** **missing** → **6.4** **stays** **conceptual** **until** **Velero** **is** **installed**

## Next

[Track 7: Capstone project](../07-Capstone-Project/README.md)
