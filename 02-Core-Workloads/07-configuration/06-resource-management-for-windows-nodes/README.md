# Resource Management for Windows Nodes — teaching transcript

## Intro

**Windows worker nodes** report **allocatable** CPU and memory differently in places (**node status**, **kubelet** flags, **host OS** scheduling) but Pods still declare **`resources`** the same way in YAML. **Windows** does not use **cgroups** the same path as **Linux**—kubelet integrates with the **Windows job object** model for limits. **CPU** and **memory** **requests** still drive **scheduler** placement; **limits** behavior should be validated per **Kubernetes** minor and **Windows Server** release. **mixed** clusters need **nodeSelector** / **affinity** so **Linux** images never land on **Windows** nodes.

**Prerequisites:** [2.7.5 kubeconfig](../05-organizing-cluster-access-using-kubeconfig-files/README.md); [2.7.4 Resources](../04-resource-management-for-pods-and-containers/README.md).

## Flow of this lesson

```
  Windows node (kubelet + OS)
              │
              ▼
  Same Pod.spec.containers[].resources in YAML
              │
              ▼
  Enforcement via Windows job objects / provider limits
              │
              ▼
  Validate per version matrix (do not assume Linux cgroup parity)
```

**Say:**

I never debug **Windows** **OOM** with **Linux** **dmesg** muscle memory—use **Windows** tooling and vendor docs.

## Learning objective

- State that **requests/limits** appear in Pod spec the same way for Windows workloads.
- Relate **Windows** resource enforcement to **kubelet** implementation differences from Linux.
- Identify **Windows** nodes in **`kubectl get nodes`**.

## Why this matters

Hybrid clusters silently **mis-schedule** when charts lack **OS** node affinity—resource lessons must mention **Windows** pools explicitly.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/07-configuration/06-resource-management-for-windows-nodes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Windows resource teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-7-6-resource-management-for-windows-nodes-notes.yaml
kubectl get cm -n kube-system 2-7-6-resource-management-for-windows-nodes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-7-6-resource-management-for-windows-nodes-notes` when RBAC allows.

---

## Step 2 — List node OS and allocatable (read-only)

**What happens when you run this:**

Separates **windows** from **linux** pools and shows **capacity**.

**Run:**

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.nodeInfo.operatingSystem}{"\t"}{.status.allocatable.cpu}{"\t"}{.status.allocatable.memory}{"\n"}{end}' 2>/dev/null | head -n 20 || true
```

**Expected:** Rows per node; **windows** appears only on hybrid clusters.

---

## Step 3 — Describe a Windows node slice (optional)

**What happens when you run this:**

**Allocatable** slice from **`kubectl describe node`** when at least one Windows node exists.

**Say:**

If **`WINNODE`** is empty, skip—**Linux-only** lab clusters have nothing to describe.

**Run:**

```bash
WINNODE="$(kubectl get nodes -l kubernetes.io/os=windows -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [ -n "$WINNODE" ]; then kubectl describe node "$WINNODE" 2>/dev/null | sed -n '/Allocatable:/,/System Info:/p'; fi
```

**Expected:** **Allocatable** block or no output if no Windows nodes.

## Video close — fast validation

```bash
kubectl get nodes -l kubernetes.io/os=windows 2>/dev/null || kubectl get nodes --show-labels 2>/dev/null | head -n 10
```

## Troubleshooting

- **No Windows nodes** → lesson is **conceptual**—still valid for hybrid planning
- **Pod stuck Pending** → **nodeSelector** missing for **windows** + **Linux** image mismatch
- **Limits seem ignored** → kubelet / **Windows** version skew—check release notes
- **Memory not as expected** → **reserved** system memory differs from Linux defaults
- **`Forbidden` notes** → offline YAML only

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-7-6-resource-management-for-windows-nodes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-7-6-resource-management-for-windows-nodes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8 Security](../../08-security/README.md)
