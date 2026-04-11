# 04 Enforcing Pod Security Standards â€” teaching transcript

## Intro

Nothing stops a developer from shipping a root container or a hostPath mount **unless** something between `kubectl apply` and etcd enforces policy.

**Pod Security Standards (PSS)** ship with Kubernetes: you label a namespace; the built-in admission plugin evaluates pods against a **level** in one of three **modes**. This lesson enforces **`restricted`** on namespace `pss-restricted`, applies a **compliant** pod, then proves a **non-compliant** pod is **rejected** when mode is `enforce`.

**Teaching tip:** Expect the non-compliant apply to return `Forbidden` â€” that is success. See **WHAT THIS DOES WHEN YOU RUN IT** in `scripts/apply-pod-security-labels.sh`.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/03-best-practices/04-pod-security-standards"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]          [ Step 2 ]          [ Step 3 ]          [ Step 4 ]
  Label namespace â†’   Apply namespace â†’   Compliant pod   â†’   Non-compliant
  with script         manifest (GitOps)   (expect OK)         pod (expect DENY)
```

**Say:**

I make sure labels exist, align the GitOps manifest, prove a hardened pod passes, then deliberately fail a bad pod so the camera sees the admission message.

---

## Levels, modes, and the 3Ã—3 matrix

**Levels** describe how strict the policy is:

- **`privileged`** â€” unrestricted.
- **`baseline`** â€” blocks the most dangerous options (host namespaces, privileged, many host volumes, â€¦).
- **`restricted`** â€” hardens workloads: non-root, dropped capabilities, read-only root filesystem where required, etc.

**Modes** describe what happens when a pod violates the **selected** level:

| Level | enforce | warn | audit |
|-------|---------|------|-------|
| **privileged** | No Pod Security checks reject pods at this level | User-facing warnings are not produced by PSS for this level | Audit annotations are not produced by PSS for this level |
| **baseline** | API **rejects** pods that break baseline rules | API **accepts** pods but `kubectl` shows **warnings** | API **accepts** pods and writes **audit** annotations for violations |
| **restricted** | API **rejects** pods that break restricted rules | API **accepts** but **warns** on violations | API **accepts** and **audits** violations |

In this lesson all three modes on `pss-restricted` point at **`restricted`**, so violations are blocked, warned, and audited together.

**Safe rollout order on existing clusters:** start with **`audit`**, fix workloads the audit surfaces, move to **`warn`**, then finally **`enforce`** so you do not mass-delete running apps.

## Step 1 â€” Apply Pod Security labels to the namespace

**What happens when you run this:**

`apply-pod-security-labels.sh` ensures `pss-restricted` exists and applies `pod-security.kubernetes.io/{enforce,warn,audit}=restricted`.

**Say:**

Idempotent script â€” safe on re-record. Labels are the entire switch for PSS.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/03-best-practices/04-pod-security-standards"
chmod +x scripts/*.sh 2>/dev/null || true
./scripts/apply-pod-security-labels.sh
```

**Expected:**

Namespace present; labels applied without error.

---

## Step 2 â€” Apply the namespace manifest

**What happens when you run this:**

`kubectl apply -f yamls/restricted-namespace.yaml` stores the same labels declaratively for GitOps workflows.

**Say:**

Real teams keep this YAML next to other namespace definitions so CI reapplies labels after edits.

**Run:**

```bash
kubectl apply -f yamls/restricted-namespace.yaml
```

**Expected:**

Namespace configured or unchanged.

---

## Step 3 â€” Apply the compliant pod

**What happens when you run this:**

`kubectl apply -f yamls/restricted-compliant-pod.yaml` admits a pod whose security context matches **`restricted`**.

**Say:**

A minimal compliant pod sets **`runAsNonRoot: true`**, **`runAsUser`** to **1000** or higher, **`allowPrivilegeEscalation: false`**, **`readOnlyRootFilesystem: true`**, and **`capabilities.drop: ["ALL"]`**. Your manifest may add volumes for writable paths â€” every `restricted` rule must still pass.

**Run:**

```bash
kubectl apply -f yamls/restricted-compliant-pod.yaml
```

**Expected:**

Pod created; `kubectl get pods -n pss-restricted` shows `Running` once the container starts.

---

## Step 4 â€” Apply the non-compliant pod (expect rejection)

**What happens when you run this:**

`kubectl apply -f yamls/restricted-noncompliant-pod.yaml` should fail with `Forbidden` because enforcement is active.

**Say:**

Read the server message aloud in the video â€” it names the failed check. That is what developers will paste into chat when policy blocks a deploy.

**Run:**

```bash
kubectl apply -f yamls/restricted-noncompliant-pod.yaml
```

**Expected:**

`Error from server (Forbidden): ...` â€” pod **not** created.

---

## Troubleshooting

- **`restricted-noncompliant-pod.yaml` creates successfully** â†’ `kubectl get ns pss-restricted --show-labels` must include `pod-security.kubernetes.io/enforce=restricted`
- **`restricted-compliant-pod.yaml` rejected** â†’ read the message; Kubernetes minor version may add stricter checks â€” compare with upstream `restricted` profile for your version
- **`Forbidden` writing namespace objects** â†’ use a cluster where you may create namespaces or ask an admin to apply the YAML
- **Production outage after labeling live namespaces** â†’ roll back to `audit`/`warn` first, fix workloads, then return to `enforce`
- **PSS not active** â†’ cluster version must be 1.23+ with PodSecurity admission enabled (default on recent kubeadm clusters)

---

## Learning objective

- Read the 3Ã—3 matrix of **levels Ã— modes** and explained what `enforce`, `warn`, and `audit` do for `baseline` and `restricted`.
- Applied `restricted` labels, shipped a compliant pod, and confirmed a non-compliant pod is **rejected**.
- Described the safe rollout order **audit â†’ warn â†’ enforce** for existing clusters.

## Why this matters

Warnings alone do not stop bad deploys. **`enforce`** turns policy into an actual guardrail â€” the same move platform teams use before they point compliance auditors at a cluster.

## Video close â€” fast validation

**What happens when you run this:**

Read-only: show labels on `pss-restricted`, list pods, dry-run the bad manifest so the API still evaluates policy without leaving objects behind.

**Say:**

I prove labels are still `restricted`, show the compliant pod, then `kubectl apply --dry-run=server` on the bad file so viewers see `Forbidden` without creating junk.

**Run:**

```bash
kubectl get ns pss-restricted --show-labels
kubectl get pods -n pss-restricted
kubectl apply -f yamls/restricted-noncompliant-pod.yaml --dry-run=server
```

**Expected:**

Labels visible; compliant pod listed; dry-run prints `Forbidden` (or equivalent) without creating the pod.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/apply-pod-security-labels.sh` | Ensures namespace + labels |
| `yamls/restricted-namespace.yaml` | Namespace with PSS labels |
| `yamls/restricted-compliant-pod.yaml` | Pod that passes `restricted` |
| `yamls/restricted-noncompliant-pod.yaml` | Pod that fails `restricted` |
| `yamls/failure-troubleshooting.yaml` | Admission troubleshooting |

---

## Next

[05 PKI certificates and requirements](../05-pki-certificates-and-requirements/README.md)
