# Windows Storage — teaching transcript

## Intro

**Windows nodes** mount storage through **Windows-specific CSI drivers** and paths: **SMB**, **iSCSI**, or cloud **Windows-compatible** disk drivers replace many Linux assumptions (**ext4**, **NFS** client in Pods). In-tree **flexVolume** and legacy patterns still appear in older docs; new work should be **CSI-first**. **Linux** images cannot run on **Windows** nodes—Stateful workloads need **Windows container** images and matching **StorageClass** **provisioners**. **Permissions** and **ACL** semantics differ from POSIX; **mount propagation** and **symlink** behavior differ from Linux **kube-proxy** paths.

**Prerequisites:** [2.6.14 Volume Health Monitoring](../14-volume-health-monitoring/README.md); [Windows networking](../../05-services-load-balancing-and-networking/10-networking-on-windows/README.md) for node context.

## Flow of this lesson

```
  Windows node pool
        │
        ▼
  Windows-aware CSI driver + StorageClass
        │
        ▼
  PVC → PV with Windows-compatible filesystem / protocol
        │
        ▼
  Windows Pod volumeMount
```

**Say:**

I never copy a **Linux StorageClass** YAML to a **Windows** pool without checking **provisioner** and **fstype**.

## Learning objective

- Contrast **Windows** storage paths with **Linux** NFS / block defaults.
- Identify **Windows** nodes and reason about **CSI** driver compatibility.

## Why this matters

Hybrid clusters fail when **Helm** charts assume **Linux-only** **mountOptions** or **fsType**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/15-windows-storage" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Windows storage teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-6-15-windows-storage-notes.yaml
kubectl get cm -n kube-system 2-6-15-windows-storage-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-15-windows-storage-notes` when allowed.

---

## Step 2 — Detect Windows nodes and storage classes

**What happens when you run this:**

Cross-check **node OS** and **StorageClass** **provisioner** list.

**Run:**

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.nodeInfo.operatingSystem}{"\n"}{end}' 2>/dev/null | head -n 15 || true
kubectl get storageclass -o yaml 2>/dev/null | grep -E 'provisioner:|^  name:' | head -n 30 || true
```

**Expected:** `windows` rows only on hybrid clusters; provisioner lines for discussion.

## Video close — fast validation

```bash
kubectl get nodes -l kubernetes.io/os=windows 2>/dev/null || true
kubectl get pvc -A 2>/dev/null | head -n 10 || true
```

## Troubleshooting

- **No Windows nodes** → lesson is **preview**—narrate for future hybrid work
- **Access denied in Pod** → Windows **RunAsUser** / **gMSA** stories—not Linux **fsGroup**
- **Wrong CSI on node** → driver **DaemonSet** must target **Windows** pool with correct **nodeSelector**
- **SMB creds** → **secret** mapping differs from cloud **dynamic** disks—read vendor chart
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-6-15-windows-storage-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-15-windows-storage-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.7 Configuration](../../07-configuration/README.md)
