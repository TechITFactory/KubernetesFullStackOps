# 2.8.6 Security for Linux Nodes — teaching transcript

## Intro

**Linux nodes** host **kubelet**, **container runtime**, **CNI**, and often **SSH** or **SSM** access. Hardening includes: **minimal OS**, timely **patches**, **firewall** rules, **restricted** **kubelet** authentication, **no** anonymous **kubelet** **read-only** exposure, **rootless** or **least-privilege** where supported, and **audit** of **sudo** / **break-glass** access. **/var/lib/kubelet** and **containerd** sockets are high-value paths—**node compromise** bypasses many **Kubernetes** **RBAC** controls ([2.8.14](../14-kubernetes-api-server-bypass-risks/README.md)).

**Prerequisites:** [2.8.5 Pod Security Policies](../05-pod-security-policies/README.md); [Track 1 — Local first operations](../../01-Local-First-Operations/README.md) if you teach node prep.

## Flow of this lesson

```
  OS + ssh/agent access
              │
              ▼
  kubelet + container runtime + CNI
              │
              ▼
  Attack surface ──► platform hardening + monitoring
```

**Say:**

**Node** **SSH** keys are **cluster-admin** in practice—protect like **HSM**-backed **break-glass**.

## Learning objective

- List major **Linux node** attack surfaces relevant to Kubernetes.
- Name **kubelet** and **runtime** hardening themes at a high level.

## Why this matters

**Container escape** + **root on node** often leads to **cluster-wide** compromise—nodes are in the **trust boundary**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/06-security-for-linux-nodes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Linux node security notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-6-security-for-linux-nodes-notes.yaml
kubectl get cm -n kube-system 2-8-6-security-for-linux-nodes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-6-security-for-linux-nodes-notes` when allowed.

---

## Step 2 — Node info and roles (read-only)

**What happens when you run this:**

Shows **OS image** and **labels** (e.g. **node-role.kubernetes.io/control-plane**).

**Run:**

```bash
kubectl get nodes -o wide 2>/dev/null | head -n 20 || true
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.node-role\.kubernetes\.io/control-plane}{"\n"}{end}' 2>/dev/null | head -n 15 || true
```

**Expected:** Node list; control-plane labels where applicable.

## Video close — fast validation

```bash
kubectl describe node 2>/dev/null | sed -n '/System Info:/,/Capacity:/p' | head -n 25 || true
```

## Troubleshooting

- **Cannot SSH** → use **bastion** / **cloud serial console** per org policy
- **kubelet not TLS** → **insecure** configs are **CVE**-class—fix bootstrap
- **CNI runs as root** → supply-chain **image** pinning and **signature** verification
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-6-security-for-linux-nodes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-6-security-for-linux-nodes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.7 Security for Windows Nodes](../07-security-for-windows-nodes/README.md)
