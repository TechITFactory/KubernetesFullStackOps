# Traces for Kubernetes system components — teaching transcript

## Intro

**Distributed** **tracing** **(OpenTelemetry**, **W3C** **trace** **context)** **helps** **follow** **requests** **through** **apiserver**, **webhooks**, **aggregated** **APIs**, **and** **admission** **chains**. **Components** **may** **export** **spans** **when** **instrumented** **and** **when** **sampling** **is** **configured**. **Cluster** **admins** **provide** **collectors**, **exporters**, **and** **tail-based** **sampling** **policies** **so** **cost** **stays** **bounded**.

**Prerequisites:** [2.11.13 System logs](../13-system-logs/README.md).

## Flow of this lesson

```
  Request enters apiserver
              │
              ▼
  Spans propagate through webhooks and etcd calls (when instrumented)
              │
              ▼
  OTLP export to collector → backend
```

**Say:**

**Tracing** **shines** **when** **`kubectl apply` feels slow** **and** **logs** **show** **nothing**—**the** **span** **waterfall** **reveals** **the** **slow** **webhook**.

## Learning objective

- Find **OpenTelemetry**/**Jaeger**/**collector** **workloads** **with** **`kubectl get pods -A`** **(read-only)**.
- Explain **sampling** **and** **PII** **risks** **for** **trace** **attributes**.

## Why this matters

**Full** **trace** **collection** **without** **sampling** **can** **cost** **more** **than** **the** **cluster** **it** **monitors**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/14-traces-for-kubernetes-system-components" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-14-traces-for-kubernetes-system-components-notes.yaml
kubectl get cm -n kube-system 2-11-14-traces-for-kubernetes-system-components-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-14-traces-for-kubernetes-system-components-notes`** when allowed.

---

## Step 2 — Trace-related pods (read-only)

**What happens when you run this:**

**Greps** **all** **namespaces** **for** **common** **collector** **names**.

**Run:**

```bash
kubectl get pods -A 2>/dev/null | grep -iE 'otel|jaeger|zipkin|tempo|collector' | head -n 20 || true
kubectl get svc -A 2>/dev/null | grep -iE 'otel|jaeger|zipkin|tempo' | head -n 15 || true
```

**Expected:** **Rows** **or** **empty** **if** **no** **tracing** **stack**.

## Video close — fast validation

```bash
kubectl api-resources 2>/dev/null | grep -i instrumentation | head -n 10 || true
```

## Troubleshooting

- **No** **spans** **for** **apiserver** → **not** **instrumented** **in** **your** **build** **or** **sampling** **zero**
- **High** **cardinality** **attributes** → **drop** **in** **collector** **pipelines**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-14-traces-for-kubernetes-system-components-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-11-14-traces-for-kubernetes-system-components-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.15 Proxies in Kubernetes](../15-proxies-in-kubernetes/README.md)
