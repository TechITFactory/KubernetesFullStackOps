# 2.8.7 Security for Windows Nodes — teaching transcript

## Intro

**Windows worker nodes** need **Windows-specific** hardening: **patch** cadence, **RDP** / **WinRM** exposure, **gMSA** for **identity**, **container** isolation boundaries, and alignment between **Kubernetes** **kubelet** and **Windows** releases. **Linux** **Pod** specs and **securityContext** fields do not always map 1:1—validate **runAsUserName**, **GMSA**, and **hostProcess** containers against Microsoft and **Kubernetes** version matrices. **Mixed** clusters must **isolate** credentials so **Linux** **break-glass** does not equal **Windows** **Domain Admin**.

**Prerequisites:** [2.8.6 Security for Linux Nodes](../06-security-for-linux-nodes/README.md).

## Flow of this lesson

```
  Windows node pool
        │
        ├── OS / AD / gMSA integration
        ├── kubelet + container runtime (Windows)
        └── workload identity + secrets handling
```

**Say:**

I cross-link **[2.7.6 Windows resources](../../07-configuration/06-resource-management-for-windows-nodes/README.md)**—**security** and **scheduling** stories belong together in hybrid clusters.

## Learning objective

- Name **Windows**-specific security concerns versus **Linux** nodes.
- Identify **Windows** nodes in **`kubectl get nodes`** for hybrid clusters.

## Why this matters

**gMSA** misconfiguration is **auth** failure and **privilege** risk at once—platform teams need a dedicated checklist.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/07-security-for-windows-nodes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Windows node security notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-7-security-for-windows-nodes-notes.yaml
kubectl get cm -n kube-system 2-8-7-security-for-windows-nodes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-7-security-for-windows-nodes-notes` when allowed.

---

## Step 2 — Detect Windows nodes (read-only)

**What happens when you run this:**

**operatingSystem** field per node.

**Run:**

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.nodeInfo.operatingSystem}{"\n"}{end}' 2>/dev/null | head -n 20 || true
```

**Expected:** **`windows`** rows only on hybrid clusters.

## Video close — fast validation

```bash
kubectl get nodes -l kubernetes.io/os=windows 2>/dev/null || true
```

## Troubleshooting

- **No Windows nodes** → conceptual lesson only
- **gMSA cred spec missing** → Pod fails **RunAsUser**—check **GMSA** CRD/chart
- **HostProcess containers** → extreme privilege—gate with **policy**
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-7-security-for-windows-nodes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-7-security-for-windows-nodes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.8 Controlling Access to the Kubernetes API](../08-controlling-access-to-the-kubernetes-api/README.md)
