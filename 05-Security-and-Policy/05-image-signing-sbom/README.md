# Image signing and SBOMs — teaching transcript

## Intro

**Vulnerability** **scanning** **answers** **“does** **this** **image** **contain** **known** **bad** **packages?”** **Signing** **answers** **“did** **this** **exact** **artifact** **come** **from** **our** **trusted** **publisher** **after** **we** **approved** **it?”** **Tools** **like** **[Sigstore** **Cosign](https://docs.sigstore.dev/cosign/overview/)** **attach** **signatures** **to** **digests**. **Clusters** **or** **admission** **policies** **can** **verify** **signatures** **before** **Pods** **run**. **The** **sample** **`Job`** **in** **`yamls/verify-verification-job.yaml`** **shows** **a** **`cosign verify`** **invocation** **pattern** **—** **keys** **and** **image** **references** **are** **placeholders** **for** **your** **registry**.

**Prerequisites:** [5.4 Admission controls](../04-admission-controls/README.md); [4.1 Pipeline design](../../04-CICD-and-GitOps/01-pipeline-design/README.md) **(image** **publish** **step)**.

## Flow of this lesson

```
  Build produces image digest + signature (out of cluster)
              │
              ▼
  Registry stores image + signature metadata
              │
              ▼
  Job or admission controller runs cosign verify before run
```

**Say:**

**SBOMs** **( SPDX**, **CycloneDX)** **pair** **with** **signing** **—** **you** **prove** **what** **is** **inside**, **not** **only** **who** **signed** **the** **tarball**.

## Learning objective

- **Explain** **why** **registry** **TLS** **alone** **does** **not** **replace** **image** **signing**.
- **Read** **the** **sample** **`Job`** **and** **list** **what** **must** **be** **true** **for** **`cosign verify`** **to** **succeed**.

## Why this matters

**Supply-chain** **attacks** **target** **the** **path** **between** **CI** **and** **the** **node** **—** **signing** **plus** **admission** **verification** **shrinks** **that** **window**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/05-Security-and-Policy/05-image-signing-sbom" 2>/dev/null || cd .
```

## Step 1 — Inspect the verification Job

**What happens when you run this:**

**You** **study** **`mock-cosign-verification`**: **container** **image** **`bitnami/cosign:latest`**, **command** **`cosign verify --key cosign.pub`**, **target** **image** **placeholder**.

**Run:**

```bash
cat yamls/verify-verification-job.yaml
```

**Expected:** **`batch/v1` `Job`**, **`restartPolicy: Never`**, **`cosign`** **args** **as** **shown** **in** **file**.

---

## Step 2 — Desk checklist for a real integration

**What happens when you run this:**

**No** **cluster** **required** **—** **list** **artifacts** **you** **must** **supply** **(public** **key**, **signed** **image**, **OIDC** **/ ** **KMS** **signer**, **admission** **policy)**.

**Say:**

**In** **production**, **this** **`Job` pattern** **moves** **into** **Kyverno** **`verifyImages`** **or** **policy** **controllers** **that** **reject** **unsigned** **images** **at** **admission**.

**Run:**

*(none)*

**Expected:** **Written** **checklist** **for** **your** **environment**.

## Video close — fast validation

**What happens when you run this:**

**If** **you** **experimentally** **`kubectl apply`** **the** **`Job`**, **remove** **it** **afterward** **—** **it** **will** **fail** **without** **valid** **keys** **and** **signed** **images**.

**Run:**

```bash
kubectl delete job mock-cosign-verification --ignore-not-found
```

**Expected:** **Job** **absent** **or** **deleted**.

## Troubleshooting

- **Job** **fails** **`ImagePullBackOff`** → **registry** **auth** **or** **rate** **limits**
- **`verify` fails** → **wrong** **digest**, **wrong** **key**, **or** **unsigned** **image**
- **Admission** **timeouts** → **optimize** **policy** **or** **cache** **verification** **results**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/verify-verification-job.yaml` | **Example** **`cosign verify`** **Job** **(placeholders)** |

## Cleanup

```bash
kubectl delete job mock-cosign-verification --ignore-not-found 2>/dev/null || true
```

## Next

[Track 6: Observability and reliability](../../06-Observability-and-Reliability/README.md)
