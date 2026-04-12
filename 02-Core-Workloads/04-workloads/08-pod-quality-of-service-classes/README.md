# Pod Quality of Service Classes — teaching transcript

## Intro

**QoS class** is derived automatically from **requests** and **limits** on **every** container in the Pod. **Guaranteed**: every container has **limits** set, and **requests equal limits** for CPU and memory (per container, for the resources that are set). **Burstable**: at least one container has **requests** set, but you do not meet Guaranteed rules (limits missing or unequal to requests on some). **BestEffort**: **no** requests and **no** limits on **any** container. Under **node pressure**, the kubelet **evicts** Pods roughly in order **BestEffort → Burstable → Guaranteed**—Guaranteed is last because it declared its minimum needs explicitly.

**Prerequisites:** [2.4.1.6 Pod Hostname](../07-pod-hostname/README.md) recommended.

## Flow of this lesson

```
  Sum per-container requests/limits
              │
              ▼
  qosClass in Pod status
              │
              ▼
  Eviction ordering under pressure (BestEffort first)
```

**Say:**

QoS is not a “priority class” API object—it is a **classification** from your resource stanza.

## Learning objective

- Classify Pods into **Guaranteed**, **Burstable**, and **BestEffort** from YAML.
- Read **`status.qosClass`** with **`kubectl`**.
- Relate QoS to **eviction** ordering during node pressure.

## Why this matters

Production “no limits” Pods become **BestEffort** and are the first evicted when a node fills—often blamed on Kubernetes “randomness.”

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/04-workloads/08-pod-quality-of-service-classes" 2>/dev/null || cd .
```

## Step 1 — Apply QoS demos and wait

**What happens when you run this:**

Manifests create Pods with different resource shapes; scheduler still places them on capable nodes.

**Say:**

I wait for **both** pods so the comparison table in step two is honest.

**Run:**

```bash
kubectl apply -f yamls/pod-qos-demo.yaml
kubectl wait --for=condition=Ready pod/qos-guaranteed --timeout=120s
kubectl wait --for=condition=Ready pod/qos-besteffort --timeout=120s
kubectl get pod qos-guaranteed qos-besteffort -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
```

**Expected:** Both pods `Running` with **distinct** `status.qosClass` values.

---

## Step 2 — Describe Guaranteed line

**What happens when you run this:**

`describe` echoes **QoS Class** in human text—matches `status.qosClass`.

**Say:**

I point at **Burstable** in real apps where developers set **requests** but forget **limits**.

**Run:**

```bash
kubectl get pod qos-guaranteed qos-besteffort -o wide
kubectl describe pod qos-guaranteed | sed -n '/QoS Class:/p'
```

**Expected:** Wide view shows nodes; QoS line reads `Guaranteed` for the guaranteed pod.

## Video close — fast validation

```bash
kubectl get pod qos-guaranteed qos-besteffort -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
```

## Troubleshooting

- **Unexpected Burstable** → check **every** container including **init** side effects; one missing limit breaks Guaranteed
- **OOM on Burstable** → limit lower than spike; raise limit or fix leak
- **BestEffort in prod** → add **requests** at minimum for scheduling fairness
- **Evicted “randomly”** → correlate with **node pressure** events and QoS class
- **Huge pages / GPU** → QoS rules consider only CPU/memory in classic tables; validate extended resources separately
- **LimitRange changes class** → defaults from namespace policy can shift effective QoS—see [2.4.2.1](../../13-workload-api/14-pod-group-policies/README.md)

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/pod-qos-demo.yaml` | Guaranteed vs BestEffort (and related) samples |
| `yamls/failure-troubleshooting.yaml` | Requests/limits mistakes |

## Cleanup

```bash
kubectl delete -f yamls/pod-qos-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.1.8 Workload Reference](../09-workload-reference/README.md)
