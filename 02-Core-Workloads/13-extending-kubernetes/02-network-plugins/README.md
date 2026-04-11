# 2.13.1.1 Network plugins — teaching transcript

## Intro

**CNI** **plugins** **implement** **Pod** **L2/L3** **connectivity**, **IP** **allocation**, **and** **sometimes** **NetworkPolicy** **enforcement**. **The** **kubelet** **invokes** **CNI** **binaries** **on** **the** **node** **using** **configuration** **under** **`/etc/cni/net.d`** **(implementation** **detail)**. **From** **the** **API**, **you** **observe** **effects** **via** **Pod** **IPs**, **Services**, **NetworkPolicies**, **and** **CNI** **DaemonSets** **in** **`kube-system`** **or** **dedicated** **namespaces**.

**Prerequisites:** [2.13.1 Compute, storage, and networking extensions](../01-compute-storage-and-networking-extensions/README.md).

## Flow of this lesson

```
  kubelet creates Pod network namespace
              │
              ▼
  CNI ADD configures interfaces and routes
              │
              ▼
  Cluster DNS and Services route traffic per plugin design
```

**Say:**

**Calico**, **Cilium**, **Azure** **CNI**, **VPC** **CNI**—**different** **data** **paths**, **same** **Pod** **spec** **surface**.

## Learning objective

- Run **repo** **inspect** **script** **(NetworkPolicy** **+** **Services)**.
- Relate **NetworkPolicy** **objects** **to** **CNI** **capabilities** **(support** **matrix)**.

## Why this matters

**Policy** **YAML** **that** **passes** **admission** **but** **is** **ignored** **by** **CNI** **gives** **a** **false** **sense** **of** **security**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/13-extending-kubernetes/02-network-plugins" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-13-1-1-network-plugins-notes.yaml
kubectl get cm -n kube-system 2-13-1-1-network-plugins-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-13-1-1-network-plugins-notes`** when allowed.

---

## Step 2 — Policies and Services (read-only)

**What happens when you run this:**

**Script** **lists** **NetworkPolicies** **cluster-wide** **and** **all** **Services**.

**Run:**

```bash
bash scripts/inspect-2-13-1-1-network-plugins.sh 2>/dev/null || true
```

**Expected:** **`kubectl get networkpolicy -A`** **and** **`kubectl get svc -A`** **output**.

## Video close — fast validation

```bash
kubectl get pods -n kube-system 2>/dev/null | grep -iE 'cni|calico|cilium|flannel|weave|antrea' | head -n 10 || true
```

## Troubleshooting

- **`networkpolicy` not** **found** → **CRD** **missing** **or** **very** **old** **cluster**
- **Policy** **no-op** → **CNI** **does** **not** **enforce** **(doc** **check)**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-13-1-1-network-plugins-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-13-1-1-network-plugins.sh` | **NetworkPolicy** **+** **Services** |

## Cleanup

```bash
kubectl delete configmap 2-13-1-1-network-plugins-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.13.1.2 Device plugins](../03-device-plugins/README.md)
