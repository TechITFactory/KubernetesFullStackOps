# Kubernetes API Server Bypass Risks — teaching transcript

## Intro

Not all cluster actions go through **`kubectl`** and the **API server**. **Bypass** paths include: **direct** **node** **access** (**SSH**, **host** **agent**) to **read** **manifests** or **copy** **etcd** **backups**, **kubelet** **HTTP** **API** **misconfiguration**, **CRI** **socket** **access** on **nodes**, **cloud** **controller** **credentials** on **workers**, **side-channel** **metadata** **services**, and **compromised** **admins** **outside** **audit** **logging**. **Defense** layers: **node** **hardening**, **network** **segmentation**, **mTLS** **kubelet**, **restricted** **SSH**, **immutable** **infrastructure**, and **detective** **controls** on **data** **exfiltration**.

**Prerequisites:** [2.8.13 Scheduler Configuration](../13-hardening-guide-scheduler-configuration/README.md); [2.8.6 Linux Nodes](../06-security-for-linux-nodes/README.md).

## Flow of this lesson

```
  Normal path: client → apiserver → etcd / nodes
        │
        └── Bypass: node shell, leaked backups, kubelet abuse, cloud IAM
```

**Say:**

**RBAC** **perfect** **plus** **shared** **SSH** **key** **to** **every** **node** **equals** **game** **over**.

## Learning objective

- List **representative** **API** **bypass** **scenarios** relevant to **Kubernetes**.
- Tie **mitigations** back to **node**, **network**, and **secrets** hygiene.

## Why this matters

**Compliance** **checkboxes** on **RBAC** **miss** **physical** / **cloud** **paths** attackers actually use.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/14-kubernetes-api-server-bypass-risks" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Bypass-risk teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-14-kubernetes-api-server-bypass-risks-notes.yaml
kubectl get cm -n kube-system 2-8-14-kubernetes-api-server-bypass-risks-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-14-kubernetes-api-server-bypass-risks-notes` when allowed.

---

## Step 2 — Node addresses (read-only)

**What happens when you run this:**

Shows **InternalIP** **surface** for **network** **zoning** **discussion**.

**Run:**

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{": "}{range .status.addresses[*]}{.type}={.address} {end}{"\n"}{end}' 2>/dev/null | head -n 15 || true
```

**Expected:** Node **address** lines.

## Video close — fast validation

```bash
kubectl get nodes -o wide 2>/dev/null | head -n 10 || true
```

## Troubleshooting

- **Teach** **only** **API** **controls** → **explicitly** **add** **node** **slide**
- **etcd** **encryption** **at** **rest** → **pair** with **backup** **encryption**
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-14-kubernetes-api-server-bypass-risks-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-14-kubernetes-api-server-bypass-risks-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.15 Linux Kernel Security Constraints for Pods and Containers](../15-linux-kernel-security-constraints-for-pods-and-containers/README.md)
