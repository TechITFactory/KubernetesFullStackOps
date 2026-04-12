# Hardening Guide — Scheduler Configuration — teaching transcript

## Intro

The **kube-scheduler** is a **control plane** component that **binds** Pods to nodes. **Hardening** topics include: **secure** **kubeconfig** and **RBAC** for the scheduler identity, **leader election** configuration, **disabling** **debug** **endpoints** on **exposed** **networks**, **supply-chain** **trust** for **scheduler** **image**, and **restricting** who may **patch** **scheduler** **configuration** (**ConfigMap** **kube-scheduler**). **Malicious** **scheduler** **config** can **exfiltrate** workloads via **predicates**—treat **scheduler** **manifests** as **high** **integrity**.

**Prerequisites:** [2.8.12 Authentication Mechanisms](../12-hardening-guide-authentication-mechanisms/README.md).

## Flow of this lesson

```
  kube-scheduler deployment / static pod
              │
              ├── RBAC identity + kubeconfig
              ├── leader election lease
              └── profile / config (policy plugins)
```

**Say:**

Few **app** **developers** touch **scheduler** **config**—**platform** **SRE** owns it alongside **API** **server** **flags**.

## Learning objective

- Explain why **scheduler** **configuration** is **security-relevant**.
- Locate **scheduler** **pods** and **leases** with **`kubectl`** (read-only).

## Why this matters

**Supply-chain** **attacks** target **less-scrutinized** **control plane** **images**—scheduler is one.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/13-hardening-guide-scheduler-configuration" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Scheduler hardening notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-13-hardening-guide-scheduler-configuration-notes.yaml
kubectl get cm -n kube-system 2-8-13-hardening-guide-scheduler-configuration-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-13-hardening-guide-scheduler-configuration-notes` when allowed.

---

## Step 2 — Find scheduler pods and leases (read-only)

**What happens when you run this:**

Labels vary (**component=kube-scheduler** vs **tier=control-plane**).

**Run:**

```bash
kubectl get pods -n kube-system 2>/dev/null | grep -i scheduler | head -n 10 || true
kubectl get lease -n kube-system 2>/dev/null | grep -i scheduler | head -n 10 || true
```

**Expected:** Scheduler pod and **lease** names on HA control planes.

## Video close — fast validation

```bash
kubectl get deploy -n kube-system 2>/dev/null | grep -i scheduler || true
```

## Troubleshooting

- **Static pod** **path** → **no** **Deployment**—**grep** **manifests** on **control plane** **node**
- **Custom** **profiles** → **v1beta1** **KubeSchedulerConfiguration** **version** **skew**
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-13-hardening-guide-scheduler-configuration-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-13-hardening-guide-scheduler-configuration-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.14 Kubernetes API Server Bypass Risks](../14-kubernetes-api-server-bypass-risks/README.md)
