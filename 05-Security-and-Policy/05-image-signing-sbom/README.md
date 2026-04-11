# 05 Image Signing and SBOMs

## Metadata
- Duration: `15 minutes`
- Difficulty: `Intermediate`
- Practical/Theory: `50/50`
- Tested on Kubernetes: `v1.30`

## Learning Objective
By the end of this lesson, you will be able to:
- Identify the necessity for Cryptographic Signatures across container payloads.
- Outline the mechanics of utilizing Sigstore's `cosign` tool to verify images.

## Why This Matters in Real Jobs
Even if you scan an image for vulnerabilities, how do you mathematically prove that a hacker didn't tamper with your Docker image *after* you uploaded it to the registry? You use an asymmetric key pair to computationally "sign" the image layer hashes. The Kubernetes admission controller will outright reject booting up any Pod whose cryptographic signature cannot be securely verified. 

## Lab: Step-by-Step Practical

### Step 1 - Open directory
**Run:**
```bash
cd "$COURSE_DIR/05-Security-and-Policy/05-image-signing-sbom"
```

### Step 2 - The Verification Job

**What happens when you run this:**
You inspect a Kubernetes Job designed to run the `cosign` binary explicitly over a registry payload to prove its cryptographic origin prior to integration.

**Say:**
In an enterprise environment, this verification isn't done linearly. It is typically integrated permanently into an Admission Controller (like Kyverno from our prior lesson) which seamlessly executes this mathematical verification transparently on every single `kubectl` applied inside the infrastructure!

**Run:**
```bash
cat yamls/verify-verification-job.yaml
```

## Next Lesson
[Track 06: Observability and Reliability](../../06-Observability-and-Reliability/01-metrics-server/README.md)
