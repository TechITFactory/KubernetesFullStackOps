# Extending the Kubernetes API — teaching transcript

## Intro

**The** **Kubernetes** **API** **extends** **through** **CustomResourceDefinitions** **(declarative** **schema** **stored** **in** **etcd)** **and** **through** **API** **aggregation**, **which** **proxies** **additional** **APIServices** **to** **extension** **servers**. **Admission** **webhooks** **and** **conversion** **webhooks** **often** **accompany** **CRDs**. **This** **folder** **frames** **those** **mechanisms**; **apply** **hands-on** **steps** **in** **2.13.2.1** **and** **2.13.2.2**.

**Prerequisites:** [2.13.1.2 Device plugins](../03-device-plugins/README.md); [2.11.7 Admission webhook good practices](../../11-cluster-administration/07-admission-webhook-good-practices/README.md).

## Flow of this lesson

```
  Need new API type or new API group implementation
              │
              ├── CRD + controllers (in-cluster schema)
              └── Aggregation + extension apiserver (delegated API server)
              │
              ▼
  kubectl api-resources grows; RBAC binds to new verbs/resources
```

**Say:**

**CRD** **puts** **data** **in** **the** **same** **etcd** **as** **core** **objects**; **aggregation** **can** **front** **a** **separate** **storage** **backend**—**that** **split** **matters** **for** **availability** **planning**.

## Learning objective

- Contrast **CRDs** **with** **aggregated** **APIServices** **at** **a** **high** **level**.
- Navigate **to** **child** **lessons** **for** **`kubectl`** **inventory** **commands**.

## Why this matters

**Platform** **teams** **choose** **CRD-only** **vs** **aggregation** **wrong** **and** **pay** **with** **upgrade** **pain** **or** **HA** **gaps**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/13-extending-kubernetes/04-extending-the-kubernetes-api" 2>/dev/null || cd .
```

## Step 1 — No in-cluster notes ConfigMap

**What happens when you run this:**

**This** **lesson** **does** **not** **ship** **`yamls/*-notes.yaml`**. **Skip** **ConfigMap** **apply**.

**Run:**

```bash
kubectl get crd --no-headers 2>/dev/null | wc -l 2>/dev/null || true
```

**Expected:** **CRD** **count** **integer** **(may** **fail** **without** **`wc` on Windows)**.

---

## Step 2 — CRDs vs aggregated APIServices (read-only)

**What happens when you run this:**

**Quantifies** **extension** **surface** **from** **the** **API**.

**Run:**

```bash
kubectl get apiservice 2>/dev/null | grep -v Local | head -n 15 || true
kubectl api-resources 2>/dev/null | grep -i custom | head -n 15 || true
```

**Expected:** **APIService** **rows** **with** **AVAILABLE=True/False**; **custom** **resource** **lines**.

## Video close — fast validation

```bash
kubectl explain crd 2>/dev/null | head -n 20 || true
```

## Troubleshooting

- **APIService** **not** **available** → **extension** **server** **down** **or** **TLS** **trust** **broken**
- **Huge** **CRD** **count** → **normal** **on** **heavily** **extended** **clusters**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| — | **No** **notes** **YAML** **in** **this** **folder** |

## Cleanup

— **none** —

## Next

[2.13.2.1 Custom resources](../05-custom-resources/README.md)
