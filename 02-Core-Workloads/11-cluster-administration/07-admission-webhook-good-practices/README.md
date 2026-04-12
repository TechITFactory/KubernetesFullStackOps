# Admission webhook good practices — teaching transcript

## Intro

**Validating** **and** **mutating** **admission** **webhooks** **intercept** **API** **requests** **before** **objects** **persist**. **Good** **practices** **include** **TLS** **with** **pinned** **CAs**, **timeouts** **and** **failure** **policies** **that** **match** **risk**, **idempotent** **mutations**, **dry-run** **compatibility**, **and** **avoiding** **hot** **loops** **that** **overload** **the** **apiserver**. **Misconfigured** **webhooks** **take** **down** **every** **`kubectl apply`** **in** **the** **cluster**.

**Prerequisites:** [2.11.6 Observability](../06-observability/README.md); [2.8.3 Pod Security Admission](../../08-security/03-pod-security-admission/README.md) **(admission** **context)**.

## Flow of this lesson

```
  API request → authentication / authorization
              │
              ▼
  Admission chain (webhooks + plugins)
              │
              ▼
  etcd persist or rejection
```

**Say:**

**I** **always** **show** **`failurePolicy: Fail`** **next** **to** **SLO** **graphs**—**that** **is** **the** **trade** **you** **sign** **when** **you** **enforce** **policy** **in** **webhooks**.

## Learning objective

- List **`ValidatingWebhookConfiguration`** **and** **`MutatingWebhookConfiguration`** **objects** **(read-only)**.
- Explain **timeout**, **failurePolicy**, **and** **sideEffects** **at** **a** **high** **level**.

## Why this matters

**Five** **hundred** **millisecond** **webhook** **latency** **multiplies** **across** **every** **controller** **reconcile**—**the** **API** **bottlenecks** **globally**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/07-admission-webhook-good-practices" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-7-admission-webhook-good-practices-notes.yaml
kubectl get cm -n kube-system 2-11-7-admission-webhook-good-practices-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-7-admission-webhook-good-practices-notes`** when allowed.

---

## Step 2 — Webhook configurations (read-only)

**What happens when you run this:**

**Shows** **which** **webhooks** **are** **registered** **cluster-wide**.

**Run:**

```bash
kubectl get validatingwebhookconfiguration 2>/dev/null | head -n 20 || true
kubectl get mutatingwebhookconfiguration 2>/dev/null | head -n 20 || true
```

**Expected:** **Webhook** **names** **(may** **be** **forbidden** **on** **restricted** **RBAC)**.

## Video close — fast validation

```bash
kubectl explain validatingwebhookconfiguration.webhooks.timeoutSeconds 2>/dev/null | head -n 12 || true
```

## Troubleshooting

- **`connection refused` on webhook** → **networkPolicy**, **service** **selector**, **TLS** **SAN**
- **Flaky** **applies** → **raise** **timeout** **or** **fix** **webhook** **performance**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-7-admission-webhook-good-practices-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-11-7-admission-webhook-good-practices-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.8 Good practices for dynamic resource allocation as a cluster admin](../08-good-practices-for-dynamic-resource-allocation-as-a-cluster-admin/README.md)
