# Track 4: CI/CD and GitOps — teaching transcript

## Intro

**Continuous** **integration** **(CI)** **turns** **commits** **into** **verified** **artifacts** **(lint**, **build**, **scan**, **publish)** **before** **anything** **reaches** **a** **registry**. **GitOps** **makes** **Git** **the** **desired-state** **source** **of** **truth** **and** **uses** **controllers** **(such** **as** **Argo** **CD)** **to** **reconcile** **the** **cluster** **with** **that** **repo**. **Progressive** **delivery** **and** **release** **strategies** **(canary**, **blue/green)** **sit** **on** **top** **of** **plain** **Services** **and** **Deployments**—**you** **still** **need** **the** **networking** **mental** **model** **from** **earlier** **tracks**.

**Prerequisites:** [Track 3: Packaging and environments](../03-Packaging-and-Environments/README.md) **(Helm**, **Kustomize**, **promotion** **basics)**; [Track 2: Core workloads](../02-Core-Workloads/README.md) **(Deployments**, **Services**, **`kubectl`)**; **optional:** **Argo** **CD** **and** **Argo** **Rollouts** **installed** **on** **your** **lab** **cluster** **for** **hands-on** **apply** **steps** **in** **4.2** **and** **4.3**.

## Flow of this lesson

```
  4.1 CI pipeline design (lint → build → scan → push)
              │
              ▼
  4.2 GitOps: Argo CD Application CR → sync from Git
              │
              ▼
  4.3 Progressive delivery: Argo Rollouts canary spec
              │
              ▼
  4.4 Blue/green with two Deployments + one Service selector flip
```

**Say:**

**I** **never** **teach** **GitOps** **without** **first** **showing** **a** **CI** **job** **that** **blocks** **on** **`trivy`** **—** **otherwise** **students** **think** **Git** **alone** **magically** **secures** **images**.

## Learning objective

- **Read** **a** **representative** **CI** **workflow** **YAML** **and** **name** **the** **gates** **between** **build** **and** **registry** **push**.
- **Explain** **GitOps** **sync** **and** **progressive** **delivery** **at** **the** **object** **level**, **then** **execute** **or** **observe** **a** **blue/green** **Service** **switch** **from** **repo** **manifests**.

## Why this matters

**Manual** **`kubectl apply` in** **production** **without** **review** **or** **reconciliation** **is** **how** **clusters** **drift** **and** **incidents** **become** **unreproducible**.

## Children (suggested order)

1. [4.1 Pipeline design](01-pipeline-design/README.md)
2. [4.2 GitOps with Argo CD](02-gitops-with-argocd/README.md)
3. [4.3 Progressive delivery](03-progressive-delivery/README.md)
4. [4.4 Release strategies](04-release-strategies/README.md)

## Module wrap — quick validation

**What happens when you run this:** **Sanity** **checks** **for** **local** **tooling** **you** **use** **in** **real** **pipelines** **(no** **cluster** **required)**.

**Say:**

**Before** **recording** **4.1**, **I** **confirm** **`helm version`** **and** **whether** **`docker`** **and** **`trivy`** **exist** **so** **I** **do** **not** **stumble** **mid-demo**.

```bash
helm version 2>/dev/null || true
docker version --format '{{.Client.Version}}' 2>/dev/null || true
command -v trivy >/dev/null 2>&1 && trivy version | head -n 2 || echo "trivy not installed (optional for live scan demo)"
```

## Troubleshooting

- **No** **Argo** **CD** **in** **cluster** → **teach** **4.2** **from** **`cat`** **and** **docs** **only**, **or** **install** **[Argo** **CD](https://argo-cd.readthedocs.io/en/stable/getting_started/)** **on** **a** **lab** **cluster**
- **Rollout** **CRD** **missing** → **install** **[Argo** **Rollouts](https://argo-rollouts.readthedocs.io/en/stable/installation/)** **before** **`kubectl apply -f`** **on** **4.3**
- **Wrong** **cluster** **context** → **`kubectl config current-context`**

## Next

Start the track at [4.1 Pipeline design](01-pipeline-design/README.md). After [4.4 Release strategies](04-release-strategies/README.md), continue to [Track 5: Security and policy — Pod security standards](../05-Security-and-Policy/01-pod-security-standards/README.md).
