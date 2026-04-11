# 2.8.16 Security Checklist — teaching transcript

## Intro

This lesson is a **cluster-operator** **checklist** **frame**: **authentication** hardening, **RBAC** **review**, **admission** (**PSA**, **policy** **engines**), **secrets** **encryption** **at** **rest**, **network** **policy** **defaults**, **node** **hardening**, **audit** **logging** **shipping**, **upgrade** **cadence**, and **backup** / **restore** **drills**. Use it after **2.8.1–2.8.15** as a **capstone** **review**—tick boxes against **your** **environment**, not **generic** **Kubernetes** **docs** **only**.

**Prerequisites:** [2.8.15 Linux Kernel Constraints](../15-linux-kernel-security-constraints-for-pods-and-containers/README.md).

## Flow of this lesson

```
  Read prior lessons
              │
              ▼
  Walk checklist categories → evidence in cluster / Git / cloud console
              │
              ▼
  Gaps → tickets with owners
```

**Say:**

I **record** **evidence** **links** (**dashboard** **URL**, **terraform** **path**) **next** **to** **each** **row** for **auditors**.

## Learning objective

- Use the **in-cluster** **notes** **ConfigMap** as a **prompt** list for **operational** **security** **reviews**.
- Produce **action** **items** from **gaps** **found** during **read-only** **kubectl** **passes**.

## Why this matters

**Ad-hoc** **hardening** **without** **checklists** **reverts** **after** **six** **months** of **feature** **pressure**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/16-security-checklist" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Operator **checklist** **text** in **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-8-16-security-checklist-notes.yaml
kubectl get cm -n kube-system 2-8-16-security-checklist-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-16-security-checklist-notes` when allowed.

---

## Step 2 — Sample evidence commands (read-only)

**What happens when you run this:**

Quick **cluster** **posture** **slice**—extend **per** **checklist** **row**.

**Run:**

```bash
kubectl get ns --show-labels 2>/dev/null | grep pod-security | head -n 10 || true
kubectl get clusterrolebinding -o jsonpath='{range .items[?(@.roleRef.name=="cluster-admin")]}{.metadata.name}{"\n"}{end}' 2>/dev/null | head -n 10 || true
kubectl get secrets -A --no-headers 2>/dev/null | wc -l 2>/dev/null || true
```

**Expected:** **PSA** **labels**, **cluster-admin** **bindings**, **secret** **count** (approximate).

## Video close — fast validation

```bash
kubectl get cm -n kube-system 2-8-16-security-checklist-notes -o jsonpath='{.data}' 2>/dev/null | head -c 500; echo
```

## Troubleshooting

- **Checklist** **too** **generic** → **fork** **YAML** **in** **git** **for** **org** **wording**
- **wc** **fails** on **Windows** **cmd** → run **in** **Git** **Bash** **or** **WSL**
- **`Forbidden` notes** → read **YAML** **from** **repo**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-16-security-checklist-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-16-security-checklist-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.17 Application Security Checklist](../17-application-security-checklist/README.md)
