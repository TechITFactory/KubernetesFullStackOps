# Cluster networking — teaching transcript

## Intro

**Cluster** **networking** **spans** **the** **CNI** **plugin** **on** **nodes**, **Service** **virtual** **IPs**, **kube-proxy** **modes** **(iptables**, **ipvs**, **or** **kernel** **routes)**, **DNS** **(CoreDNS)**, **and** **NetworkPolicy** **enforcement**. **Admin** **lessons** **focus** **on** **how** **packets** **move** **and** **where** **to** **look** **when** **Services** **or** **DNS** **break**—**not** **on** **rewriting** **CNI** **binaries** **live** **in** **class**.

**Prerequisites:** [2.11.4 Certificates](../04-certificates/README.md); [2.5 Services](../../05-services-load-balancing-and-networking/README.md) **(module** **entry)**.

## Flow of this lesson

```
  Pod network namespace + CNI
              │
              ▼
  Service VIP → kube-proxy / dataplane implementation
              │
              ▼
  Cluster DNS and policy (optional CNI support)
```

**Say:**

**When** **`curl` from Pod fails**, **I** **check** **DNS** **then** **Service** **Endpoints** **then** **NetworkPolicy**—**that** **order** **saves** **hours**.

## Learning objective

- List **Services** **and** **Endpoints** **across** **namespaces** **(read-only)**.
- Explain **why** **CNI** **choice** **affects** **NetworkPolicy** **support**.

## Why this matters

**Half** **of** **“Kubernetes** **is** **slow”** **tickets** **are** **DNS** **or** **conntrack** **exhaustion** **under** **the** **hood**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/05-cluster-networking" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-5-cluster-networking-notes.yaml
kubectl get cm -n kube-system 2-11-5-cluster-networking-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-5-cluster-networking-notes`** when allowed.

---

## Step 2 — Services, endpoints slice, kube-system network pods (read-only)

**What happens when you run this:**

**Surfaces** **routing** **targets** **and** **common** **CNI**/**DNS** **DaemonSets** **in** **kube-system**.

**Run:**

```bash
kubectl get svc -A 2>/dev/null | head -n 20 || true
kubectl get endpoints -A 2>/dev/null | head -n 15 || true
kubectl get pods -n kube-system -o wide 2>/dev/null | grep -iE 'cni|calico|cilium|flannel|weave|core-dns|dns' | head -n 15 || true
```

**Expected:** **Truncated** **tables**; **CNI/DNS** **lines** **or** **empty** **on** **managed** **planes**.

## Video close — fast validation

```bash
kubectl get networkpolicy -A 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **Endpoints** **empty** → **selector** **mismatch** **or** **no** **ready** **Pods**
- **Policy** **deny-all** **default** → **explicit** **egress** **to** **kube-dns**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-5-cluster-networking-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-11-5-cluster-networking-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.6 Observability](../06-observability/README.md)
