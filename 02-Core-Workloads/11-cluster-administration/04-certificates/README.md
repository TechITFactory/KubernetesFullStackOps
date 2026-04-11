# 2.11.4 Certificates — teaching transcript

## Intro

**Kubernetes** **uses** **TLS** **everywhere**: **apiserver**, **kubelet**, **etcd**, **aggregated** **APIs**, **webhooks**, **and** **service** **mesh** **sidecars**. **Cluster** **operators** **rotate** **signing** **CAs**, **approve** **kubelet** **CSRs**, **and** **monitor** **expiry**. **`CertificateSigningRequest`** **objects** **surface** **pending** **kubelet** **and** **client** **cert** **flows** **you** **can** **see** **with** **`kubectl`**.

**Prerequisites:** [2.11.3 Node autoscaling](../03-node-autoscaling/README.md); [2.8 Security](../../08-security/README.md) **(TLS** **and** **identity** **context)**.

## Flow of this lesson

```
  Component needs identity
              │
              ▼
  CSR or control-plane signer issues cert
              │
              ▼
  Rotation before expiry (automation or runbook)
```

**Say:**

**I** **teach** **`kubectl get csr`** **before** **opening** **OpenSSL**—**most** **students** **never** **needed** **PEM** **math** **on** **day** **one**.

## Learning objective

- List **CertificateSigningRequests** **and** **interpret** **pending** **vs** **approved** **states**.
- Name **major** **Kubernetes** **TLS** **surfaces** **(apiserver**, **kubelet**, **etcd)**.

## Why this matters

**Expired** **apiserver** **certs** **take** **the** **whole** **control** **plane** **offline**—**rotation** **automation** **is** **non-negotiable** **at** **scale**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/04-certificates" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-4-certificates-notes.yaml
kubectl get cm -n kube-system 2-11-4-certificates-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-4-certificates-notes`** when allowed.

---

## Step 2 — CSRs and API server address (read-only)

**What happens when you run this:**

**Inspect** **script** **lists** **CSRs**; **cluster-info** **anchors** **the** **apiserver** **endpoint** **students** **trust**.

**Run:**

```bash
bash scripts/inspect-2-11-4-certificates.sh 2>/dev/null || true
kubectl cluster-info 2>/dev/null | head -n 5 || true
```

**Expected:** **CSR** **table** **(may** **be** **empty)**; **cluster-info** **line**.

## Video close — fast validation

```bash
kubectl get csr -o wide 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **Pending** **CSRs** **forever** → **controller** **not** **running** **or** **RBAC**
- **Webhook** **TLS** **errors** → **CA** **bundle** **in** **WebhookConfiguration**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-4-certificates-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-11-4-certificates.sh` | **`kubectl get csr`** |

## Cleanup

```bash
kubectl delete configmap 2-11-4-certificates-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.5 Cluster networking](../05-cluster-networking/README.md)
