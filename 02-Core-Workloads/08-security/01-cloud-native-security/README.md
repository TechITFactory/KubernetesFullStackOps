# 2.8.1 Cloud Native Security — teaching transcript

## Intro

**Cloud-native security** frames risk across the **lifecycle**: **build** (images, SBOM, signing), **supply chain** (registries, provenance), **deploy** (manifests, GitOps), **runtime** (Kubernetes policy, network controls), and **detect/respond** (audit logs, SIEM). The **4Cs** (Cloud, Cluster, Container, Code) remind you that **Kubernetes** is one layer—misconfigured **IAM** or **VPC** can bypass the best **Pod Security**. This lesson anchors vocabulary before **PSS**, **RBAC**, and **admission** drills.

**Prerequisites:** [2.8 Security module](../README.md).

## Flow of this lesson

```
  Code ─► Container ─► Cluster ─► Cloud / platform
     │         │            │
     └─────────┴────────────┴── shared responsibility
```

**Say:**

I tell teams: **Kubernetes RBAC** does not fix **public S3 buckets**—map controls to the right **C**.

## Learning objective

- Name layers of **defense in depth** for Kubernetes-hosted workloads.
- Relate this module’s lessons to **build**, **runtime**, and **platform** controls.

## Why this matters

Compliance asks “who is responsible for **encryption**?”—without layering, everyone assumes someone else did it.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/01-cloud-native-security" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Teaching notes in **kube-system** when RBAC allows.

**Run:**

```bash
kubectl apply -f yamls/2-8-1-cloud-native-security-notes.yaml
kubectl get cm -n kube-system 2-8-1-cloud-native-security-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-1-cloud-native-security-notes` created or **Forbidden**.

---

## Step 2 — Read-only cluster “posture” snapshot

**What happens when you run this:**

Skim **namespaces** and **nodes**—no mutation.

**Run:**

```bash
kubectl get ns 2>/dev/null | head -n 20
kubectl get nodes -o wide 2>/dev/null | head -n 15 || true
```

**Expected:** Baseline inventory for discussion.

## Video close — fast validation

```bash
kubectl cluster-info 2>/dev/null || true
kubectl version -o yaml 2>/dev/null | sed -n '1,20p' || true
```

## Troubleshooting

- **`Forbidden` apply** → teach from git YAML
- **No cloud context in kubectl** → **cluster-info** still shows API endpoint for narrative
- **Over-focus on K8s** → explicitly mention **IdP**, **registry**, **CI** in **Say** blocks
- **Wrong cluster** → **`kubectl config current-context`**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-1-cloud-native-security-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-1-cloud-native-security-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.2 Pod Security Standards](../02-pod-security-standards/README.md)
