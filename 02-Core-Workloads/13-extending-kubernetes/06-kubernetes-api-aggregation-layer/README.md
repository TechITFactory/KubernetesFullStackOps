# 2.13.2.2 Kubernetes API aggregation layer — teaching transcript

## Intro

**API** **aggregation** **lets** **the** **kube-apiserver** **delegate** **specific** **API** **groups** **to** **extension** **API** **servers** **via** **`APIService`** **objects**. **The** **extension** **server** **must** **serve** **TLS** **trusted** **by** **the** **apiserver** **and** **honor** **authentication** **headers** **from** **the** **main** **apiserver**. **When** **aggregation** **breaks**, **`kubectl`** **may** **show** **`APIService`** **rows** **with** **`AVAILABLE=False`**.

**Prerequisites:** [2.13.2.1 Custom resources](../05-custom-resources/README.md); [2.11.4 Certificates](../../11-cluster-administration/04-certificates/README.md).

## Flow of this lesson

```
  Register APIService pointing to extension Service
              │
              ▼
  Aggregator proxies requests with client cert / auth headers
              │
              ▼
  Extension server serves group/version/resources
```

**Say:**

**Metrics** **server** **and** **some** **metrics** **APIs** **are** **the** **examples** **students** **already** **touched** **in** **metrics** **lessons**—**aggregation** **is** **not** **only** **for** **exotic** **vendors**.

## Learning objective

- List **`APIService`** **objects** **and** **interpret** **`AVAILABLE`** **column**.
- Explain **why** **TLS** **trust** **between** **apiserver** **and** **extension** **server** **matters**.

## Why this matters

**Broken** **aggregation** **blocks** **HPA** **custom** **metrics**, **service** **catalog** **style** **APIs**, **and** **vendor** **extensions** **cluster-wide**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/13-extending-kubernetes/06-kubernetes-api-aggregation-layer" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-13-2-2-kubernetes-api-aggregation-layer-notes.yaml
kubectl get cm -n kube-system 2-13-2-2-kubernetes-api-aggregation-layer-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-13-2-2-kubernetes-api-aggregation-layer-notes`** when allowed.

---

## Step 2 — APIService health (read-only)

**What happens when you run this:**

**Shows** **delegated** **services** **and** **availability**.

**Run:**

```bash
kubectl get apiservice 2>/dev/null | head -n 25 || true
kubectl get apiservice 2>/dev/null | grep -v True | grep -v Local | head -n 15 || true
```

**Expected:** **Full** **table**; **subset** **of** **not-fully-available** **rows** **(may** **be** **noisy)**.

## Video close — fast validation

```bash
kubectl explain apiservice.spec 2>/dev/null | head -n 30 || true
```

## Troubleshooting

- **`AVAILABLE=False`** → **Service** **endpoints**, **cert** **SANs**, **networkPolicy**
- **Version** **skew** **between** **aggregated** **group** **and** **clients** → **upgrade** **ordering**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-13-2-2-kubernetes-api-aggregation-layer-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-13-2-2-kubernetes-api-aggregation-layer-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.13.3 Operator pattern](../07-operator-pattern/README.md)
