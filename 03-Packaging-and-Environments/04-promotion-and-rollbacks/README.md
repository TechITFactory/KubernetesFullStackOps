# Promotion and rollbacks — teaching transcript

## Intro

**Helm** **tracks** **each** **`helm upgrade`** **as** **a** **new** **revision**. **`helm history`** **lists** **those** **revisions**; **`helm rollback`** **recreates** **prior** **manifest** **state** **while** **appending** **another** **history** **entry** **(rollback** **does** **not** **erase** **the** **mistake** **from** **the** **log)**. **This** **lesson** **promotes** **a** **release** **with** **a** **new** **values** **file** **then** **rolls** **back** **to** **revision** **1**.

**Prerequisites:** [3.3 Environment separation](../03-environment-separation/README.md); [3.2 Helm charting strategies](../02-helm-charting-strategies/README.md); **Helm** **v3**.

## Flow of this lesson

```
  helm install (baseline revision 1)
              │
              ▼
  helm upgrade -f values-v2.yaml (revision 2)
              │
              ▼
  helm rollback <release> 1 → new revision 3 pointing at rev 1 manifest
```

**Say:**

**Revision** **3** **after** **rollback** **surprises** **people**—**history** **is** **append-only**; **the** **cluster** **state** **matches** **rev** **1**, **not** **time** **travel** **deleting** **rev** **2**.

## Learning objective

- **Drive** **`helm upgrade`** **with** **a** **values** **file** **and** **read** **`helm history`**.
- **Execute** **`helm rollback`** **and** **re-verify** **history** **and** **workload** **image/tag**.

## Why this matters

**Fast** **rollback** **reduces** **MTTR** **when** **a** **bad** **image** **or** **config** **ships**—**if** **you** **practice** **it** **before** **the** **incident**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/03-Packaging-and-Environments/04-promotion-and-rollbacks" 2>/dev/null || cd .
```

## Step 1 — Install baseline release

**What happens when you run this:**

**Deploys** **`mission-critical`** **from** **the** **shared** **simple-app** **chart** **with** **defaults** **(nginx** **1.24)** **into** **the** **current** **namespace** **(typically** **`default`)**.

**Run:**

```bash
helm install mission-critical ../02-helm-charting-strategies/yamls/simple-app
helm ls
```

**Expected:** **Release** **at** **revision** **1**; **Pods** **Running**.

---

## Step 2 — Promote with upgrade

**What happens when you run this:**

**Applies** **`values-v2.yaml`** **(higher** **replica** **count** **and** **`1.25` tag)** **as** **revision** **2**.

**Run:**

```bash
cat yamls/values-v2.yaml
helm upgrade mission-critical ../02-helm-charting-strategies/yamls/simple-app -f yamls/values-v2.yaml
```

**Expected:** **Upgrade** **success**; **history** **shows** **revision** **2**.

---

## Step 3 — Inspect history after upgrade

**What happens when you run this:**

**Prepares** **narrative** **for** **rollback** **(even** **if** **workload** **still** **healthy)**.

**Run:**

```bash
helm history mission-critical
kubectl get pods -o wide
```

**Expected:** **At** **least** **revisions** **1** **and** **2**; **Pods** **reflect** **v2** **settings**.

---

## Step 4 — Roll back to revision 1

**What happens when you run this:**

**Restores** **manifests** **from** **revision** **1** **and** **records** **revision** **3** **as** **the** **rollback** **event**.

**Run:**

```bash
helm rollback mission-critical 1
helm history mission-critical
```

**Expected:** **Revision** **3** **with** **description** **indicating** **rollback** **to** **1**; **workload** **returns** **to** **baseline** **image/tag** **from** **rev** **1**.

---

## Step 5 — Verify workload state

**What happens when you run this:**

**Confirms** **the** **Deployment** **created** **by** **Helm** **(`<release>-<chart.name>`)** **matches** **post-rollback** **expectations**.

**Run:**

```bash
kubectl get deploy mission-critical-simple-app -o jsonpath='{.spec.replicas} replicas, image={.spec.template.spec.containers[0].image}{"\n"}' 2>/dev/null || kubectl get deploy
```

**Expected:** **`replicas`** **and** **`image`** **match** **revision** **1** **(defaults** **from** **chart** **`values.yaml`:** **`nginx:1.24`**, **`replicaCount: 1`)** **unless** **you** **overrode** **install** **values**.

## Video close — fast validation

**What happens when you run this:**

**Uninstalls** **the** **release** **and** **removes** **managed** **resources** **for** **this** **lab**.

**Run:**

```bash
helm uninstall mission-critical
helm ls
```

**Expected:** **No** **`mission-critical`** **row** **in** **`helm ls`**.

## Troubleshooting

- **`has no deployed releases`** → **release** **was** **uninstalled** **already**—**re-run** **Step** **1**
- **Upgrade** **leaves** **old** **ReplicaSets** → **normal**—**Kubernetes** **keeps** **history** **until** **GC**
- **Deploy** **name** **differs** → **`helm get manifest mission-critical | grep kind: -A2`** **or** **`kubectl get deploy`**
- **Wrong** **namespace** → **add** **`-n`** **consistently** **to** **all** **`helm`** **commands**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/values-v2.yaml` | **Promotion** **values** **(e.g.** **tag** **1.25**, **replicas** **3)** |

## Cleanup

```bash
helm uninstall mission-critical 2>/dev/null || true
```

## Next

[Track 4: CI/CD and GitOps — pipeline design](../../04-CICD-and-GitOps/01-pipeline-design/README.md)
