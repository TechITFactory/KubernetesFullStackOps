# 07 Turnkey Cloud Solutions â€” teaching transcript

## Intro

Sections **01** and **02** were about **building** Kubernetes yourself. Many teams instead buy a **managed control plane** (EKS, GKE, AKS, and others): the cloud runs API server, scheduler, controller-manager, and etcd; you still run worker nodes (unless you choose a serverless node model), workloads, networking, RBAC, and cost discipline.

This lesson gives an honest comparison, a decision frame, a CLI readiness script, and a structured provider note manifest â€” without creating cloud resources in the script path.

**Teaching tip:** **WHAT THIS DOES WHEN YOU RUN IT** is in `scripts/cloud-readiness-check.sh`.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/02-production-environment/07-turnkey-cloud-solutions"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]           [ Step 2 ]              [ Step 3 ]
  cloud-readiness  â†’   read provider      â†’   record decision
  script               comparison YAML         (team wiki / Git)
```

**Say:**

I check which CLIs and credentials are alive, I read the comparison YAML on disk, then I write down what we chose and why â€” that last step is culture, not kubectl.

---

## Step 1 â€” Run the cloud readiness script

**What happens when you run this:**

`cloud-readiness-check.sh` prints which cloud CLIs exist, runs light auth checks where possible, and shows the current `kubectl` context â€” it does **not** create clusters.

**Say:**

Expired cloud credentials are the main reason ten-minute `eksctl` or `terraform apply` runs fail at the end. I run this at the start of every provisioning session.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/02-production-environment/07-turnkey-cloud-solutions"
chmod +x scripts/*.sh 2>/dev/null || true
./scripts/cloud-readiness-check.sh
```

**Expected:**

Table-style output listing installed tools and auth hints; your wording may vary with script version.

---

## Step 2 â€” Read the provider comparison manifest

**What happens when you run this:**

`cat` prints `yamls/turnkey-cloud-options.yaml` â€” read-only documentation in the repo.

**Say:**

I use this as a checklist: control-plane cost model, node flexibility, managed node options â€” not marketing bullets from memory.

**Run:**

```bash
cat yamls/turnkey-cloud-options.yaml
```

**Expected:**

Structured YAML or text comparing major providers (content ships in-repo).

---

## Step 3 â€” Walk the decision tree (Say only)

**What happens when you run this:**

No commands â€” you apply the tree to your organisation.

**Say:**

Small teams usually default to managed. If Kubernetes **is** your product, you may still self-manage. Compliance may force on-prem. If none of those exceptions apply and you do not need exotic control-plane flags, managed is the efficient default.

**Run:**

_(Discuss with your team.)_

**Expected:**

A written decision: provider + rationale + who owns upgrades.

### Decision tree (ASCII)

```
  Team < ~5 engineers?
        â”‚
        â”œâ”€ yes â”€â”€â–¶ strong bias to managed
        â”‚
        â””â”€ no â”€â”€â–¶ Is K8s your product?
                    â”‚
                    â”œâ”€ yes â”€â”€â–¶ self-managed / distro path
                    â”‚
                    â””â”€ no â”€â”€â–¶ Compliance blocks public cloud?
                                â”‚
                                â”œâ”€ yes â”€â”€â–¶ on-prem or private cloud
                                â”‚
                                â””â”€ no â”€â”€â–¶ Need custom control-plane APIs?
                                            â”‚
                                            â”œâ”€ yes â”€â”€â–¶ self-managed or verify provider limits
                                            â””â”€ no â”€â”€â–¶ managed â€” pick cloud already in use
```

---

## What managed does and does not cover

**Provider typically manages:** API server, scheduler, controller-manager, etcd, control-plane upgrades, control-plane certs, multi-AZ control plane.

**You still manage:** worker nodes (unless Autopilot/Fargate-style), add-ons (Ingress, cert-manager, monitoring), application YAML, VPC and security groups, RBAC, and **cost**.

**Trade-off:** you lose SSH into the control plane and accept provider upgrade schedules; you gain engineering time back.

---

## Provider snapshot (illustrative)

| Provider | Service | Notes |
|----------|---------|--------|
| AWS | EKS | Common default when already on AWS |
| Google | GKE / Autopilot | Autopilot bills per pod request |
| Azure | AKS | Control plane free tier subject to change |
| DigitalOcean | DOKS | Simple clusters for smaller teams |
| Civo | Civo Kubernetes | Lightweight option for labs |

Exact pricing changes â€” treat the YAML manifest and vendor pages as source of truth.

---

## Troubleshooting

- **`aws: command not found` (or gcloud/az)** â†’ install the CLIs for clouds you actually use; the script is informational
- **`Unable to locate credentials`** â†’ refresh SSO, access keys, or `gcloud auth login` before provisioning
- **`kubectl` context points at minikube** â†’ `kubectl config use-context` to the intended cloud context before mutating cloud clusters
- **Believing managed means â€œno opsâ€** â†’ you still patch nodes, tune network policy, and watch the bill
- **Ignoring Part 2 after choosing managed** â†’ the Kubernetes API and workloads behave the same; concepts still apply

---

## Learning objective

- Ran `cloud-readiness-check.sh` and interpreted CLI/auth output.
- Explained what managed Kubernetes includes versus what the customer still owns.
- Used the ASCII decision tree to justify a platform choice for a sample team.

## Why this matters

Choosing managed versus self-managed is a capacity and risk decision, not a purity test. Naming the trade-offs early prevents half the team from building kubeadm while the other half opens an EKS console.

## Video close â€” fast validation

**What happens when you run this:**

Re-runs the readiness script, prints kubectl context, then `kubectl get nodes` or a single echo â€” no provisioning. `2>/dev/null || true` on `get nodes` avoids failing the close when no cloud API is reachable.

**Say:**

Same trio I run before any terraform or eksctl apply: readiness script, context, quick node list if the API answers.

**Run:**

```bash
./scripts/cloud-readiness-check.sh
kubectl config current-context
kubectl get nodes -o wide 2>/dev/null || echo "No cluster context or API unreachable â€” fix auth/context before provisioning."
```

**Expected:**

Readiness output; context name; either node table or the echo line.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/cloud-readiness-check.sh` | CLI + auth + context snapshot |
| `yamls/turnkey-cloud-options.yaml` | Provider comparison / decision record |
| `yamls/failure-troubleshooting.yaml` | Access and networking readiness hints |

---

## Next

Continue to [Part 2 Concepts](../../../part-2-concepts/README.md) when your syllabus says so â€” concepts apply identically on managed clusters. From the repo root, run `bash part-2-concepts/scripts/verify-part2-prerequisites.sh` before **2.1**.
