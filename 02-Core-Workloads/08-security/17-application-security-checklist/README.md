# 2.8.17 Application Security Checklist — teaching transcript

## Intro

**Application** **security** on Kubernetes adds **workload** concerns: **non-root** **containers**, **read-only** **root** **fs**, **minimal** **images**, **dependency** **scanning**, **TLS** **everywhere**, **mTLS** **service** **mesh** **(optional)**, **ingress** **WAF** **(optional)**, **secrets** **injection** **patterns**, **SBOM**, **runtime** **threat** **detection**, and **safe** **defaults** in **Helm** **values**. Pair this with [2.8.16](../16-security-checklist/README.md): **platform** **checklist** **plus** **app** **checklist** **equals** **defense** **in** **depth**.

**Prerequisites:** [2.8.16 Security Checklist](../16-security-checklist/README.md).

## Flow of this lesson

```
  Image build → deploy manifest → runtime behavior → observability
        │              │                  │
        └──────────────┴──────────────────┴── app-owned controls
```

**Say:**

**Platform** **team** **owns** **PSA**; **app** **team** **owns** **SQL** **injection** **fixes**—both **show** **up** **in** **incidents**.

## Learning objective

- Differentiate **platform** **security** **controls** from **application** **security** **controls** on Kubernetes.
- Use the **notes** **ConfigMap** as a **developer** **onboarding** **prompt** list.

## Why this matters

**Hardened** **cluster** **with** **vulnerable** **app** **code** **still** **leaks** **PII**—checklists **assign** **ownership**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/17-application-security-checklist" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Application **checklist** **text** in **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-8-17-application-security-checklist-notes.yaml
kubectl get cm -n kube-system 2-8-17-application-security-checklist-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-17-application-security-checklist-notes` when allowed.

---

## Step 2 — Inspect a sample Deployment security posture (read-only)

**What happens when you run this:**

First **Deployment** in **default** **namespace**—skip if **none**.

**Run:**

```bash
D="$(kubectl get deploy -n default -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [ -n "$D" ]; then kubectl get deploy "$D" -n default -o jsonpath='{.spec.template.spec.containers[0].securityContext}{"\n"}' 2>/dev/null; fi || true
```

**Expected:** **securityContext** **JSON** or **empty**.

## Video close — fast validation

```bash
kubectl get deploy -A 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **No** **Deployments** → **use** **DaemonSet** **or** **StatefulSet** **example** **instead**
- **Checklist** **vs** **framework** **duplication** → **map** **OWASP** **items** **to** **K8s** **artifacts**
- **`Forbidden` notes** → **read** **from** **git**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-17-application-security-checklist-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-17-application-security-checklist-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.9 Policies](../09-policies/README.md)
