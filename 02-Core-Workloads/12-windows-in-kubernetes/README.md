# Windows in Kubernetes — teaching transcript

## Intro

**Windows** **worker** **nodes** **run** **Windows** **containers** **with** **a** **different** **kernel**, **runtime**, **and** **networking** **stack** **than** **Linux** **nodes**. **Hybrid** **clusters** **schedule** **Pods** **onto** **the** **correct** **OS** **using** **node** **labels** **(`kubernetes.io/os`)**, **taints**, **and** **RuntimeClass** **where** **needed**. **Storage**, **Service** **mesh**, **and** **security** **features** **may** **differ** **from** **Linux** **—** **always** **check** **support** **matrices** **for** **your** **Kubernetes** **and** **CNI** **versions**.

**Prerequisites:** [2.11 Cluster administration](../11-cluster-administration/README.md); [2.4 Workloads](../04-workloads/README.md) **(Pod** **and** **Scheduling** **basics)**.

## Flow of this lesson

```
  Hybrid cluster: Linux + Windows node pools
              │
              ▼
  OS-specific images and node selectors
              │
              ▼
  Networking, storage, and ops runbooks differ per OS
```

**Say:**

**I** **open** **`kubectl get nodes -L kubernetes.io/os`** **before** **any** **Windows** **YAML**—**students** **must** **see** **where** **workloads** **can** **land**.

## Learning objective

- Explain **why** **Windows** **containers** **require** **Windows** **nodes** **and** **matching** **images**.
- Navigate **the** **two** **lessons** **from** **concepts** **to** **operational** **guide**.

## Why this matters

**Wrong** **node** **OS** **or** **image** **combo** **fails** **at** **scheduling** **or** **runtime** **with** **opaque** **errors** **if** **you** **skip** **basics**.

## Children (suggested order)

1. [2.12.1 Windows containers in Kubernetes](01-windows-containers-in-kubernetes/README.md)
2. [2.12.2 Guide for running Windows containers in Kubernetes](02-guide-for-running-windows-containers-in-kubernetes/README.md)

## Module wrap — quick validation

**What happens when you run this:** **Node** **OS** **labels** **and** **Windows** **version** **hints** **when** **present**.

**Say:**

**No** **Windows** **nodes** **in** **the** **lab** **cluster** **is** **fine**—**teach** **the** **label** **contract** **anyway**.

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.kubernetes\.io/os}{"\t"}{.metadata.labels.node\.kubernetes\.io/windows-build}{"\n"}{end}' 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **Pod** **stuck** **Pending** → **missing** **Windows** **node** **pool**, **taints**, **or** **selector**
- **Image** **pull** **errors** → **wrong** **architecture** **or** **OS** **in** **manifest**
- **Wrong** **cluster** → **`kubectl config current-context`**

## Next

[2.13 Extending Kubernetes](../13-extending-kubernetes/README.md)
