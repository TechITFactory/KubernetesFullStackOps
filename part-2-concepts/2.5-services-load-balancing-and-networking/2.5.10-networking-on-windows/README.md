# 2.5.10 Networking on Windows — teaching transcript

## Intro

**Windows nodes** run a different **kubelet**, **container runtime** path, and historically **Windows-specific kube-proxy** implementations compared to Linux. **CNIs** must support **Windows data planes** (often **Overlay** or **host-gw** modes with **VXLAN**); mismatches between Linux and Windows **CNI** versions cause **partial** cluster networking. **Services** still exist with the same **API**, but packet paths differ—**NodePort**, **LoadBalancer**, and **Ingress** behavior should be validated per vendor matrix. **Linux-only** manifests (privileged **hostPath**, certain **securityContext** fields) will not schedule on Windows—separate DaemonSets per OS are common.

**Prerequisites:** [2.5.1 Service](../2.5.1-service/README.md).

## Flow of this lesson

```
  Hybrid cluster (Linux + Windows nodes)
              │
              ├── Linux: standard CNI + kube-proxy path
              │
              └── Windows: Windows CNI + kube-proxy / datapath variant
```

**Say:**

I never assume a **DaemonSet** that mounts **/var/run** on Linux runs on Windows without a **nodeSelector**.

## Learning objective

- Identify **Windows** nodes from **`kubectl get nodes`** output.
- Name differences in **CNI**, **kube-proxy**, and **Service datapath** vs Linux.
- Relate **hybrid** clusters to **OS-specific** workload manifests.

## Why this matters

Enterprise clusters often add a **Windows** pool for .NET workloads—Linux networking muscle memory misleads debugging.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.5-services-load-balancing-and-networking/2.5.10-networking-on-windows" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Windows networking notes.

**Run:**

```bash
kubectl apply -f yamls/2-5-10-networking-on-windows-notes.yaml
kubectl get cm -n kube-system 2-5-10-networking-on-windows-notes -o name
```

**Expected:** ConfigMap in `kube-system` when allowed.

---

## Step 2 — List nodes and OS images

**What happens when you run this:**

**Windows** nodes show **Windows** in **OS-IMAGE** or **`kubernetes.io/os=windows`** label when operators set it.

**Run:**

```bash
kubectl get nodes -o wide 2>/dev/null | head -n 20
```

**Expected:** Linux-only labs show Linux nodes only; hybrid clusters show Windows rows.

## Video close — fast validation

```bash
kubectl get nodes -l kubernetes.io/os=windows 2>/dev/null || kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.nodeInfo.operatingSystem}{"\n"}{end}'
```

## Troubleshooting

- **Pods stuck Pending on Windows** → image OS/arch mismatch; use **Windows container** images
- **Service reachable Linux→Windows inconsistent** → CNI **overlay** misconfiguration
- **kube-proxy Windows version skew** → match **Kubernetes** minor with vendor guidance
- **Ingress only hits Linux nodes** → controller **DaemonSet** may lack Windows tolerations—by design
- **HNS / VFP issues** → Windows host networking—use platform support channels
- **No Windows nodes** → lesson is **preview** content; narration still valid

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-5-10-networking-on-windows-notes.yaml` | Notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | CNI skew, host-gw/VXLAN, Service path differences |

## Cleanup

```bash
kubectl delete configmap 2-5-10-networking-on-windows-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.5.11 Service ClusterIP Allocation](2.5.11-service-clusterip-allocation/README.md)
