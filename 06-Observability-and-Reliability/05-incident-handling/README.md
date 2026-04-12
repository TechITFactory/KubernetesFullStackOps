# Incident handling — teaching transcript

## Intro

**Most** **production** **triage** **starts** **with** **`kubectl get`** **and** **`kubectl describe`** **because** **Events** **embed** **kubelet**, **scheduler**, **and** **controller** **messages** **close** **to** **the** **object** **they** **refer** **to**. **`ImagePullBackOff`** **is** **a** **classic** **symptom** **with** **a** **short** **list** **of** **root** **causes** **(bad** **tag**, **private** **registry** **auth**, **rate** **limits**, **arch/os** **mismatch)**. **This** **lesson** **applies** **`crashing-pod`** **with** **a** **non-existent** **image** **tag** **and** **reads** **Events**.

**Prerequisites:** [6.4 Backup and DR](../04-backup-and-dr/README.md); [Track 2: Core workloads](../../02-Core-Workloads/README.md) **(Pod** **lifecycle)**.

## Flow of this lesson

```
  Pod stuck in ImagePullBackOff / ErrImagePull
              │
              ▼
  kubectl describe pod → Events section
              │
              ▼
  Fix image, secret, or network → Pod recovers or replace workload
```

**Say:**

**Scroll** **to** **the** **bottom** **of** **`describe` first** **—** **the** **top** **is** **often** **stale** **desired** **state**.

## Learning objective

- **Use** **`kubectl describe pod`** **to** **extract** **failure** **events** **for** **a** **broken** **image** **reference**.
- **Outline** **a** **minimal** **triage** **order** **(events** **→** **image** **→** **pull** **secret** **→** **registry)**.

## Why this matters

**Mean** **time** **to** **recovery** **dominates** **SLOs** **during** **outages** **—** **fast** **`describe` habits** **save** **money**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/06-Observability-and-Reliability/05-incident-handling" 2>/dev/null || cd .
```

## Step 1 — Create the failing Pod

**What happens when you run this:**

**Applies** **`crashing-pod`** **using** **`nginx:non_existent_tag`**.

**Run:**

```bash
kubectl apply -f yamls/broken-image-pod.yaml
kubectl get pod crashing-pod
```

**Expected:** **Pod** **in** **`ImagePullBackOff`** **or** **`ErrImagePull`** **(names** **may** **vary** **by** **generator** **—** **manifest** **sets** **`metadata.name: crashing-pod`)**.

---

## Step 2 — Read Events on the Pod

**What happens when you run this:**

**Shows** **kubelet** **and** **container** **runtime** **errors** **at** **the** **bottom** **of** **`describe`**.

**Say:**

**Copy** **the** **exact** **`Failed`** **message** **into** **the** **incident** **ticket** **—** **future** **you** **will** **thank** **present** **you**.

**Run:**

```bash
kubectl describe pod crashing-pod
```

**Expected:** **Events** **mention** **failed** **pull**, **not** **found**, **or** **manifest** **unknown**.

## Video close — fast validation

**What happens when you run this:**

**Deletes** **the** **lab** **Pod**.

**Run:**

```bash
kubectl delete pod crashing-pod --ignore-not-found
```

**Expected:** **Pod** **gone**.

## Troubleshooting

- **No** **`crashing-pod`** → **wrong** **namespace** **—** **add** **`-n`**
- **Events** **empty** → **API** **server** **clock**, **event** **TTL**, **or** **RBAC** **to** **events**
- **Real** **registry** **auth** **issues** → **`kubectl create secret docker-registry`** **and** **`imagePullSecrets`**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/broken-image-pod.yaml` | **Pod** **with** **invalid** **image** **tag** |

## Cleanup

```bash
kubectl delete pod crashing-pod --ignore-not-found 2>/dev/null || true
```

## Next

[Track 7: Capstone project](../../07-Capstone-Project/README.md)
