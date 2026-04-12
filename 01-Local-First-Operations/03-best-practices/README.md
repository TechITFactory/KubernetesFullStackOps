# 03 Best Practices

## Intro

Production clusters fail for predictable reasons: **capacity**, **topology**, **node health**, **policy drift**, and **certificate expiry**. This module teaches **repeatable checks** and **secure defaults** so your Part 1 cluster behaves like something you could hand to another engineer.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/03-best-practices"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  03.1               02              03            03.4              03.5
  Scale           →   Multi-zone     →   Node         →   Pod Security   →   PKI
  readiness           resilience         validation        Standards          health
```

**Say:**

Five lessons in order: large-cluster readiness, spreading work across zones, validating Linux nodes before join, enforcing Pod Security Standards with namespaces, then reading and renewing control-plane certificates. Each lesson adds another production gate.

---

## Step 1 — Run module readiness (read-only)

**What happens when you run this:**

The script in `scripts/verify-1-3-module-readiness.sh` checks whatever prerequisites the authors encoded (kubectl context, cluster reachability, etc.) — read-only aside from whatever the script prints.

**Say:**

Before I touch policy or PKI labs, I run the module gate from the **03** folder so I know `kubectl` points at the cluster I think it does.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/03-best-practices"
bash scripts/verify-1-3-module-readiness.sh
```

**Expected:**

Script exits `0` with OK-style output (wording depends on script version).

---

## Step 2 — Open the first child lesson (reading step)

**What happens when you run this:**

You open [01 Considerations for large clusters](03.1-considerations-for-large-clusters/README.md) and continue through **03.5** in order unless your environment forces you to prioritize **03** before joining fragile nodes.

**Say:**

I read **03.1** first for scheduling and API habits, then zones, then node validation — unless I am about to join a real node, in which case I jump to **03** early.

**Run:**

_(Follow the **Children** links below.)_

**Expected:**

You are in lesson **03.1** with a plan to reach **03.5**.

---

## Troubleshooting

- **`verify-1-3-module-readiness.sh: No such file or directory`** → `cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/03-best-practices"` first
- **`error: You must be logged in to the server`** → refresh kubeconfig credentials before any **03** lab
- **Lessons reference files not found** → confirm `COURSE_DIR` points at your clone root
- **`Forbidden` applying **03.4** or **03.5** manifests** → your user may lack cluster-admin; use a lab cluster or ask for elevated RBAC
- **Skipping straight to Part 2 without **03**** → allowed, but you miss operational guardrails that Part 2 assumes you have heard once

---

## Learning objective

- Ran the **03** readiness script from `$COURSE_DIR` and navigated the five-lesson sequence.
- Mapped which lesson covers scale, zones, nodes, Pod Security Standards, and PKI.
- Chose when to prioritize node validation (**03**) ahead of the printed order.

## Why this matters

Teams that skip these habits discover them as outages: thundering herds on one node, zone-wide surprises, bad sysctl defaults, permissive pods, or expired API certificates. The module turns those into planned checks instead of surprises.

## Video close — fast validation

**What happens when you run this:**

Wide node list, all pods, then the newest cluster events — a read-only triage picture.

**Say:**

After **03.5** I still run this snapshot after any node, CNI, or admission change — nodes wide, every pod, last events.

**Run:**

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get events -A --sort-by=.lastTimestamp | tail -n 30
```

**Expected:**

All nodes `Ready`; system namespaces stable or intentionally `Completed`; no unexplained repeating `Failed` / `BackOff` / admission errors.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/verify-1-3-module-readiness.sh` | Gate before starting **03** labs |
| `03.1-considerations-for-large-clusters/` | Scale readiness script + topology sample |
| `02-running-in-multiple-zones/` | Zone labels + spread demo |
| `03-validate-node-setup/` | Node prerequisite script |
| `03.4-enforcing-pod-security-standards/` | PSS manifests + helper script |
| `03.5-pki-certificates-and-requirements/` | PKI inspection script + runbooks |

---

## Outcomes

After this module you should be able to:

- Explain why **large clusters**, **multi-zone**, and **node validation** matter before you add workloads.
- Apply **Pod Security Standards** labels at the namespace level and know where to look when admission blocks a pod.
- Read **PKI layout** on a control-plane node and know when cert rotation is urgent.
- Run a **verify-before-change** habit: nodes → system pods → events → targeted `describe`.

## Cross-cutting topics (where to learn them)

This module focuses on **cluster-level** habits. Several “day-2 workload” topics appear again in Part 2 — use the table so you know what 03 covers vs what comes next.

| Topic | In this module | Also see |
|--------|----------------|----------|
| **Resource requests & limits** | Namespace **ResourceQuota** and **LimitRange** patterns in [03 local dev workspace](../01-learning-environment/03-local-development-clusters/README.md) | [Kubernetes workloads concepts](https://kubernetes.io/docs/concepts/workloads/); course **2.4** when lessons are complete |
| **Liveness / readiness probes** | Mentioned in large-cluster and node-readiness context | **2.4 Workloads** (Pods), production runbooks |
| **Security contexts** (runAsUser, capabilities) | **03.4** Pod Security Standards (admission-level guardrails) | **2.8 Security** in this course |
| **PodDisruptionBudgets** | **03.1** scale and availability mindset | **2.10 Scheduling** when expanded |

For **Kubernetes version skew** and “what we test against,” see [`KUBERNETES_VERSION_MATRIX.md`](../../KUBERNETES_VERSION_MATRIX.md) at the repo root.

---

## Children (work in order)

- [01 Considerations for large clusters](03.1-considerations-for-large-clusters/README.md)
- [02 Running in multiple zones](02-running-in-multiple-zones/README.md)
- [03 Validate node setup](03-validate-node-setup/README.md)
- [04 Enforcing Pod Security Standards](03.4-enforcing-pod-security-standards/README.md)
- [05 PKI certificates and requirements](03.5-pki-certificates-and-requirements/README.md)

---

## Next

Continue to [Part 2: Concepts](../../02-Core-Workloads/README.md) — run `bash 02-Core-Workloads/scripts/verify-part2-prerequisites.sh` from the repo root first.
