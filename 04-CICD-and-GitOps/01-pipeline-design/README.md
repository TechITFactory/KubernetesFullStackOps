# Pipeline design — teaching transcript

## Intro

**A** **CI** **pipeline** **is** **the** **contract** **between** **developers** **and** **production:** **every** **merge** **runs** **the** **same** **steps** **(checkout**, **lint**, **build**, **vulnerability** **scan**, **push** **to** **a** **trusted** **registry)** **so** **bad** **images** **never** **earn** **a** **digest** **operators** **would** **deploy**. **This** **lesson** **uses** **a** **GitHub** **Actions-style** **workflow** **file** **in** **`yamls/ci-pipeline.yaml`** **as** **a** **readable** **blueprint** **—** **you** **do** **not** **have** **to** **run** **it** **on** **GitHub** **to** **learn** **the** **stages**.

**Prerequisites:** [Track 4 module](../README.md); [Track 3: Packaging](../../03-Packaging-and-Environments/README.md) **(Helm** **charts** **mentioned** **in** **the** **sample** **lint** **step)**.

## Flow of this lesson

```
  git push → workflow triggers
              │
              ▼
  lint (helm lint) → build image → trivy scan → push
              │
              ▼
  any failure stops the line before registry push
```

**Say:**

**The** **scan** **sits** **between** **build** **and** **push** **on** **purpose** **—** **once** **the** **image** **is** **in** **the** **registry**, **every** **consumer** **treats** **it** **as** **trusted**.

## Learning objective

- **Identify** **lint**, **build**, **security** **scan**, **and** **publish** **stages** **in** **the** **sample** **workflow**.
- **Explain** **why** **scanning** **after** **build** **but** **before** **push** **reduces** **risk**.

## Why this matters

**Pushing** **unscanned** **images** **means** **your** **registry** **becomes** **a** **cache** **of** **known** **vulnerable** **layers** **—** **GitOps** **will** **happily** **sync** **them** **everywhere**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/04-CICD-and-GitOps/01-pipeline-design" 2>/dev/null || cd .
```

## Step 1 — Inspect the CI blueprint

**What happens when you run this:**

You **read** **a** **structured** **workflow** **with** **jobs** **and** **steps** **that** **mirror** **common** **enterprise** **gates**.

**Say:**

**Point** **out** **`helm lint charts/my-app`** **—** **it** **is** **cheap** **and** **catches** **chart** **errors** **before** **Docker** **even** **runs**.

**Run:**

```bash
cat yamls/ci-pipeline.yaml
```

**Expected:** **`on: push`**, **job** **`build-and-push`**, **steps** **checkout** **→** **lint** **→** **build** **→** **`trivy image`** **→** **`docker push`**.

---

## Step 2 — Trace failure modes (desk exercise)

**What happens when you run this:**

**No** **commands** **required** **—** **walk** **the** **YAML** **and** **state** **what** **fails** **closed** **if** **lint**, **build**, **or** **Trivy** **exits** **non-zero**.

**Say:**

**If** **`trivy`** **fails**, **the** **push** **step** **never** **runs** **—** **that** **is** **the** **whole** **point** **of** **ordering**.

**Run:**

*(Optional)* **Open** **the** **file** **in** **your** **editor** **and** **annotate** **each** **step** **with** **“blocks** **release”** **or** **“does** **not** **block”**.

**Expected:** **Clear** **narrative** **that** **only** **a** **green** **pipeline** **reaches** **registry** **push**.

---

## Step 3 — Optional local smoke (if tools exist)

**What happens when you run this:**

**If** **you** **have** **a** **chart** **at** **`charts/my-app`** **and** **Helm** **installed**, **`helm lint`** **validates** **the** **same** **class** **of** **gate** **as** **the** **workflow** **—** **skip** **if** **paths** **do** **not** **exist** **in** **this** **repo**.

**Run:**

```bash
helm version 2>/dev/null || true
test -d charts/my-app && helm lint charts/my-app || echo "Skip: no charts/my-app in this repo (sample workflow only)"
```

**Expected:** **Helm** **version** **or** **skip** **message**.

## Video close — fast validation

**What happens when you run this:**

**Re-read** **the** **trigger** **and** **branch** **filter** **—** **quick** **mental** **check** **before** **ending** **the** **segment**.

**Run:**

```bash
grep -E '^(name:|on:|jobs:)' yamls/ci-pipeline.yaml 2>/dev/null || true
```

**Expected:** **`name: CI Pipeline Example`**, **`on: push`**, **`jobs:`** **visible**.

## Troubleshooting

- **Workflow** **references** **paths** **you** **do** **not** **have** → **normal** **for** **a** **sample** **—** **fork** **paths** **for** **your** **repo** **or** **teach** **read-only**
- **`trivy` not** **installed** → **install** **from** **[Aqua** **Security** **docs](https://aquasecurity.github.io/trivy/)** **or** **use** **CI** **only**
- **Different** **CI** **platform** → **same** **stages** **map** **to** **Jenkins**, **GitLab** **CI**, **Azure** **Pipelines**, **etc.**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/ci-pipeline.yaml` | **Example** **GitHub** **Actions-style** **CI** **workflow** |

## Cleanup

— **none** **(this** **lesson** **does** **not** **apply** **cluster** **objects)** —

## Next

[4.2 GitOps with Argo CD](../02-gitops-with-argocd/README.md)
