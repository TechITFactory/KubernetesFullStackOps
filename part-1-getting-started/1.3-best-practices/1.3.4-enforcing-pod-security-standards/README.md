# 1.3.4 Enforcing Pod Security Standards — teaching transcript

- **Summary**: Pod Security Standards should be enforced intentionally with namespace labels and validated with both compliant and non-compliant example workloads.
- **Content**: PSS levels and their intent, namespace labeling automation, enforce/warn/audit mode differences, and admission testing with real manifests.
- **Lab**: Label a namespace for `restricted` enforcement, apply a compliant manifest successfully, then observe a non-compliant manifest fail admission.

## Assets

- `scripts/apply-pod-security-labels.sh`
- `yamls/restricted-namespace.yaml`
- `yamls/restricted-compliant-pod.yaml`
- `yamls/restricted-noncompliant-pod.yaml`
- `yamls/failure-troubleshooting.yaml`

**Teaching tip:** Expect the **noncompliant** pod apply to be **rejected** by admission — that is the correct behaviour. If it is accepted, enforcement is not active. See **WHAT THIS DOES WHEN YOU RUN IT** in `scripts/apply-pod-security-labels.sh`.

---

## Intro

Here's the problem with security in Kubernetes.

Nothing prevents a developer from deploying a pod that runs as root, mounts the host filesystem, or uses `hostNetwork: true` — unless you put something in between the `kubectl apply` and the API server.

**Pod Security Standards** (PSS) is that thing. It's built into Kubernetes since 1.23, requires no extra software, and works by labeling namespaces. The admission controller reads those labels and either warns, audits, or blocks pods that don't comply.

There are three levels:

| Level | What it allows |
|-------|----------------|
| `privileged` | Everything. No restrictions. |
| `baseline` | Blocks the most dangerous configurations (hostNetwork, privileged containers, host path mounts). Allows running as root. |
| `restricted` | Enforces security best practice: no root, read-only root filesystem, dropped capabilities, non-root user required. |

And three modes:

| Mode | What it does |
|------|-------------|
| `enforce` | Rejects non-compliant pods |
| `warn` | Allows the pod but prints a warning to the user |
| `audit` | Allows the pod but logs an audit event — useful for discovering violations without breaking anything |

In this lesson we'll enforce `restricted` on a namespace and confirm both sides — compliant pods go in, non-compliant pods are blocked.

---

## Flow of this lesson

**Say:**
Four steps. Label the namespace, apply a namespace manifest for good measure, then test both the compliant and non-compliant pods. The non-compliant one failing is the pass condition.

```
  [ Step 1 ]          [ Step 2 ]          [ Step 3 ]          [ Step 4 ]
  Label namespace →   Apply namespace →   Test compliant  →   Test non-
  with PSS labels     manifest            pod (expect OK)     compliant pod
                                                              (expect DENIED)
```

---

## Step 1 — Apply Pod Security labels to the namespace

**What happens when you run this:**
`apply-pod-security-labels.sh` ensures the namespace `pss-restricted` exists, then runs `kubectl label` to apply three labels:
- `pod-security.kubernetes.io/enforce: restricted`
- `pod-security.kubernetes.io/warn: restricted`
- `pod-security.kubernetes.io/audit: restricted`

All three modes set to `restricted` — violations are blocked, warned, and audited simultaneously.

**Say:**
The script is idempotent — running it again on an already-labeled namespace just updates the labels without error. I run it this way because namespace security labels are easy to accidentally remove or overwrite with a `kubectl apply` that doesn't include them.

**Run:**

```bash
./scripts/apply-pod-security-labels.sh
```

**Expected:**
Namespace `pss-restricted` created or confirmed; labels applied without error.

---

## Step 2 — Apply the namespace manifest

**What happens when you run this:**
`kubectl apply -f yamls/restricted-namespace.yaml` applies the full namespace manifest including PSS labels. This is an alternative or complement to the script — useful when you manage namespace definitions in GitOps.

**Say:**
In a real team you'd typically keep namespace definitions in Git and apply them via CI/CD. This manifest is the GitOps-friendly version of what the script does. Applying both is safe — they converge on the same state.

**Run:**

```bash
kubectl apply -f yamls/restricted-namespace.yaml
```

**Expected:**
Namespace configured or unchanged.

---

## Step 3 — Apply the compliant pod

**What happens when you run this:**
`kubectl apply -f yamls/restricted-compliant-pod.yaml` sends a pod manifest to the API server. The admission controller checks it against the `restricted` policy on `pss-restricted`. The pod is compliant — it runs as a non-root user, drops all capabilities, and has a read-only root filesystem — so admission succeeds.

**Say:**
Here's what a `restricted`-compliant pod needs. Four fields that most default manifests are missing:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop: ["ALL"]
```

Without all of these, the pod fails `restricted` admission. Let's confirm the compliant one goes through.

**Run:**

```bash
kubectl apply -f yamls/restricted-compliant-pod.yaml
```

**Expected:**
Pod admitted and created. `kubectl get pods -n pss-restricted` shows it Running.

---

## Step 4 — Apply the non-compliant pod (expect rejection)

**What happens when you run this:**
`kubectl apply -f yamls/restricted-noncompliant-pod.yaml` sends a pod that runs as root or requests privileges that `restricted` blocks. The admission controller rejects it and returns an error describing which policy checks failed.

**Say:**
This is the important one. The rejection message tells you exactly which field violated the policy — it names the check (e.g. `runAsNonRoot`, `allowPrivilegeEscalation`) and the namespace label that triggered it.

Read the rejection message. This is the same message a developer on your team would see if they deployed a non-compliant workload. Understanding it means you can help them fix it.

**Run:**

```bash
kubectl apply -f yamls/restricted-noncompliant-pod.yaml
```

**Expected:**
`Error from server (Forbidden): ...` — the pod is **rejected**. This is the correct outcome. If it is accepted, the namespace labels are not set to `enforce` mode — re-check Step 1.

---

## Rolling out PSS safely in an existing cluster

Enforcing `restricted` on a namespace with existing workloads will break them if they don't comply. The safe rollout pattern:

1. Start with `audit` mode only — violations are logged but nothing breaks.
2. Check audit logs for violations: `kubectl get events -n <namespace>` and audit log filtering.
3. Fix the workloads that are flagged.
4. Move to `warn` mode — violations show as warnings, developers see them immediately.
5. After all warnings are resolved, move to `enforce`.

This approach lets you discover compliance gaps without causing an outage.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/apply-pod-security-labels.sh` | Idempotent: ensures namespace + PSS labels |
| `yamls/restricted-namespace.yaml` | Namespace manifest with PSS labels for GitOps |
| `yamls/restricted-compliant-pod.yaml` | Pod that passes `restricted` admission |
| `yamls/restricted-noncompliant-pod.yaml` | Pod that fails `restricted` admission |
| `yamls/failure-troubleshooting.yaml` | Policy mismatch, admission errors, label syntax |

---

## Troubleshooting

- **Non-compliant pod is accepted** → labels not on the namespace; run `kubectl get ns pss-restricted --show-labels`; confirm `pod-security.kubernetes.io/enforce: restricted` is present
- **Compliant pod rejected** → check the rejection message; the compliant manifest may be missing a field for your Kubernetes version's `restricted` policy definition
- **Existing workloads broken after labeling** → switch to `warn` mode first; audit the violations; fix workloads before enforcing
- **Not seeing warnings** → confirm you're using Kubernetes 1.23+; PSS is GA from 1.25

---

## Learning objective

- Explain the three PSS levels and three enforcement modes.
- Apply PSS labels to a namespace and confirm enforce mode is active.
- Read and interpret a PSS rejection message.
- Describe the safe rollout path for enforcing PSS on existing workloads.

## Why this matters

Security is only real when non-compliant workloads are actually blocked. Awareness and warning modes are a step — enforcement is the goal. PSS lets you get there without deploying an admission webhook or buying a third-party tool.

---

## Video close — fast validation

**What happens when you run this:**
Shows namespace labels; lists pods in the namespace; re-applies the non-compliant pod to confirm enforcement is still active.

**Say:**
The last line is the key one — if the non-compliant pod is still denied, enforcement is working. If it's accepted, something changed the labels. I run this after any namespace configuration change.

```bash
kubectl get ns pss-restricted --show-labels
kubectl get pods -n pss-restricted
kubectl apply -f yamls/restricted-noncompliant-pod.yaml
```

---

## Next

[1.3.5 PKI certificates and requirements](../1.3.5-pki-certificates-and-requirements/README.md)
