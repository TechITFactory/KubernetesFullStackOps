# Track 3: Packaging and environments — teaching transcript

## Intro

**Packaging** **Kubernetes** **manifests** **for** **multiple** **environments** **is** **how** **teams** **avoid** **forking** **YAML** **per** **cluster** **or** **copy-pasting** **fifty** **microservice** **repos**. **This** **track** **covers** **Kustomize** **(bases** **and** **overlays)**, **Helm** **(charts**, **values**, **releases)**, **namespace** **and** **values-file** **separation**, **and** **Helm** **upgrades** **/ ** **rollbacks** **as** **promotion** **mechanics**. **Everything** **here** **builds** **on** **plain** **`kubectl`** **and** **the** **workload** **objects** **you** **already** **know** **from** **[Track** **2](../02-Core-Workloads/README.md)**.

**Prerequisites:** [02-Core-Workloads](../02-Core-Workloads/README.md) **(Pods**, **Deployments**, **Services**, **`kubectl`)**; **a** **working** **cluster** **(minikube**, **kind**, **or** **equivalent)**; **for** **lessons** **3.2–3.4**, **[Helm** **v3](https://helm.sh/docs/intro/install/)** **installed**.

## Flow of this lesson

```
  3.1 Kustomize: base + overlays → kubectl apply -k / kustomize build
              │
              ▼
  3.2 Helm: Chart + values → helm install / template
              │
              ▼
  3.3 Same chart, different namespaces + values files
              │
              ▼
  3.4 helm upgrade, history, rollback, uninstall
```

**Say:**

**I** **always** **show** **`kubectl kustomize`** **or** **`helm template`** **before** **`apply`/`install`**—**the** **rendered** **YAML** **is** **the** **contract** **with** **the** **API**.

## Learning objective

- **Render** **and** **apply** **Kustomize** **overlays** **from** **this** **repo** **without** **editing** **the** **base** **by** **hand** **per** **environment**.
- **Install** **and** **mutate** **Helm** **releases** **using** **values** **files** **and** **recover** **with** **`helm rollback`**.

## Why this matters

**GitOps** **and** **CI/CD** **tracks** **assume** **you** **can** **package** **differences** **(dev** **vs** **prod)** **safely**—**this** **module** **is** **that** **foundation**.

## Children (suggested order)

1. [3.1 Kustomize bases and overlays](01-kustomize-bases-overlays/README.md)
2. [3.2 Helm charting strategies](02-helm-charting-strategies/README.md)
3. [3.3 Environment separation](03-environment-separation/README.md)
4. [3.4 Promotion and rollbacks](04-promotion-and-rollbacks/README.md)

## Module wrap — quick validation

**What happens when you run this:** **Quick** **checks** **that** **Helm** **and** **Kustomize** **CLIs** **are** **available** **(read-only** **/ ** **no** **cluster** **mutation)**.

**Say:**

**Before** **recording** **3.3**, **I** **confirm** **`helm version`** **prints** **v3** **so** **release** **namespaces** **behave** **as** **expected**.

```bash
kubectl version --client=true -o yaml 2>/dev/null | head -n 15 || true
helm version 2>/dev/null || true
```

## Troubleshooting

- **`helm: command not found`** → **install** **Helm** **v3** **before** **lessons** **3.2–3.4**
- **`error: unknown shorthand flag: 'k'`** → **kubectl** **too** **old** **for** **built-in** **Kustomize**—**upgrade** **client** **or** **use** **`kustomize build`**
- **Wrong** **cluster** → **`kubectl config current-context`**

## Next

Start the track at [3.1 Kustomize bases and overlays](01-kustomize-bases-overlays/README.md). After [3.4 Promotion and rollbacks](04-promotion-and-rollbacks/README.md), continue to [Track 4: CI/CD and GitOps — pipeline design](../04-CICD-and-GitOps/01-pipeline-design/README.md).
