# Compute, storage, and networking extensions — teaching transcript

## Intro

**Kubernetes** **delegates** **three** **big** **infrastructure** **concerns** **to** **plugins**: **networking** **(CNI)**, **volumes** **(CSI)**, **and** **devices** **(device** **plugins)**. **The** **core** **defines** **Pod**, **NetworkPolicy**, **PVC**, **and** **resource** **requests** **APIs**; **vendors** **implement** **behavior** **on** **nodes** **and** **in** **control** **plane** **controllers**. **This** **folder** **is** **the** **parent** **overview**—**hands-on** **steps** **live** **in** **2.13.1.1** **and** **2.13.1.2**.

**Prerequisites:** [2.13 module](../README.md); [2.6 Storage](../../06-storage/README.md) **(volume** **vocabulary)**; [2.5 Networking](../../05-services-load-balancing-and-networking/README.md) **(Services** **and** **policies)**.

## Flow of this lesson

```
  Pod spec declares network + volumes + resource requests
              │
              ▼
  CNI / CSI / device plugin implementations satisfy spec on nodes
              │
              ▼
  Observability and upgrades are vendor-specific runbooks
```

**Say:**

**When** **someone** **says** **“Kubernetes** **networking** **is** **broken”**, **my** **first** **question** **is** **“which** **CNI?”** **not** **“which** **Service** **type?”**.

## Learning objective

- Name **CNI**, **CSI**, **and** **device** **plugins** **as** **the** **three** **primary** **infrastructure** **extension** **points**.
- Link **from** **this** **overview** **to** **the** **child** **lessons** **for** **`kubectl`** **demos**.

## Why this matters

**Blaming** **upstream** **Kubernetes** **for** **CNI** **IPAM** **bugs** **or** **CSI** **attach** **timeouts** **misroutes** **escalations**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/13-extending-kubernetes/01-compute-storage-and-networking-extensions" 2>/dev/null || cd .
```

## Step 1 — No in-cluster notes ConfigMap

**What happens when you run this:**

**This** **lesson** **does** **not** **ship** **`yamls/*-notes.yaml`**. **Skip** **ConfigMap** **apply**; **use** **Step** **2** **for** **read-only** **discovery** **and** **the** **child** **READMEs** **for** **deeper** **labs**.

**Run:**

```bash
kubectl version -o jsonpath='{.serverVersion.gitVersion}{"\n"}' 2>/dev/null || true
```

**Expected:** **Server** **version** **string** **or** **error**.

---

## Step 2 — Quick extension hints (read-only)

**What happens when you run this:**

**Surfaces** **CSI/CNI-related** **API** **kinds** **when** **installed**.

**Run:**

```bash
kubectl api-resources 2>/dev/null | grep -iE 'csi|volumeattachment|networkpolicy|cni' | head -n 20 || true
```

**Expected:** **Zero** **or** **more** **rows** **depending** **on** **cluster**.

## Video close — fast validation

```bash
kubectl get pods -n kube-system 2>/dev/null | head -n 12 || true
```

## Troubleshooting

- **Overwhelming** **vendor** **CRDs** → **filter** **by** **api-group** **with** **`kubectl api-resources`**
- **No** **matches** **in** **grep** → **older** **cluster** **or** **different** **spelling**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| — | **No** **notes** **YAML** **in** **this** **folder** |

## Cleanup

— **none** **(no** **ConfigMap** **applied)** —

## Next

[2.13.1.1 Network plugins](../02-network-plugins/README.md)
