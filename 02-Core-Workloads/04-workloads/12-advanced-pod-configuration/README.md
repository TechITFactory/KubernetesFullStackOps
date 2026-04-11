# 2.4.1.11 Advanced Pod Configuration â€” teaching transcript

## Intro

Complex Pods are where **scheduling**, **security**, **storage**, **networking**, and **lifecycle** intersect in one object. This lesson names the heavy-hitter fields with a **one-line purpose** each: **`nodeSelector`** pins Pods to nodes with matching labelsâ€”use for simple â€œGPU onlyâ€ or â€œzone Aâ€ cases. **`tolerations`** let Pods schedule onto **tainted** nodes (including control-plane nodes for system workloads). **Affinity / anti-affinity** express **soft or hard** rules about **co-locating** or **spreading** Pods across topology domains. **`priorityClassName`** influences **preemption** and queueing when the cluster is overcommitted. **`terminationGracePeriodSeconds`** sets how long kubelet waits between **SIGTERM** and **SIGKILL** during shutdownâ€”pair with **preStop** hooks from [2.3.4](../../../2.3-containers/2.3.4-container-lifecycle-hooks/README.md).

**Prerequisites:** [2.4.1.10 Downward API](../11-downward-api/README.md) recommended.

## Flow of this lesson

```
  advanced-pod-demo.yaml
        â”‚
        â”œâ”€â”€ scheduling: nodeSelector / affinity / tolerations
        â”œâ”€â”€ priorityClassName
        â”œâ”€â”€ security contexts
        â””â”€â”€ terminationGracePeriodSeconds
```

**Say:**

I walk the manifest top to bottom on camera and pause on anything that could make the Pod **Pending** forever.

## Learning objective

- State the purpose of **nodeSelector**, **tolerations**, **affinity/anti-affinity**, **priorityClassName**, and **terminationGracePeriodSeconds**.
- Read a live Pod YAML and point to each section.

## Why this matters

Half of â€œKubernetes is slowâ€ tickets are **Pending** Pods with a toleration typo or impossible anti-affinity.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.4-workloads/01-pods/12-advanced-pod-configuration" 2>/dev/null || cd .
```

## Step 1 â€” Apply and wait

**What happens when you run this:**

If constraints are unsatisfiable, the Pod stays **Pending**â€”teachable failure.

**Say:**

Before apply I warn that **demo manifests** may assume labels that do not exist on every lab cluster.

**Run:**

```bash
kubectl apply -f yamls/advanced-pod-demo.yaml
kubectl wait --for=condition=Ready pod/advanced-pod-demo --timeout=120s
kubectl get pod advanced-pod-demo -o yaml | sed -n '1,50p'
```

**Expected:** Advanced pod fields from the manifest are visible in live object YAML; Ready if constraints match your cluster.

---

## Step 2 â€” Security and QoS slice

**What happens when you run this:**

`describe` highlights **securityContext** and **QoS class** togetherâ€”common interview slice.

**Say:**

If **Priority** or **QoS** surprise you, scroll up to **resources** and **priorityClassName** in spec.

**Run:**

```bash
kubectl describe pod advanced-pod-demo | sed -n '/Security Context:/,/QoS Class:/p'
kubectl get pod advanced-pod-demo -o wide
```

**Expected:** Security context lines and QoS class printed; wide view shows scheduling result.

## Video close â€” fast validation

```bash
kubectl get pod advanced-pod-demo -o wide
kubectl describe pod advanced-pod-demo | sed -n '/Node-Selectors:/,/Tolerations:/p'
```

## Troubleshooting

- **`Pending` + FailedScheduling** â†’ unsatisfiable **affinity** or missing **nodeSelector** labels
- **Tolerations ignored** â†’ wrong **operator** or **effect**; compare to `kubectl describe node`
- **Preemption loops** â†’ **priorityClass** too aggressive; check cluster quota
- **Immediate SIGKILL on delete** â†’ **terminationGracePeriodSeconds** too low for your app
- **`Forbidden`** â†’ Pod Security / SCC / OPA blocked fields in **securityContext**
- **Image pull despite â€œadvancedâ€ title** â†’ scheduling passed; debug registry separately

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/advanced-pod-demo.yaml` | Combined scheduling + security + lifecycle fields |
| `yamls/failure-troubleshooting.yaml` | Constraint and sysctl failures |

## Cleanup

```bash
kubectl delete -f yamls/advanced-pod-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.2 Workload API](../../13-workload-api/README.md)
