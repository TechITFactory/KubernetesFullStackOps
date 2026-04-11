# 1.3 Best Practices

Production clusters fail for predictable reasons: **capacity**, **topology**, **node health**, **policy drift**, and **certificate expiry**. This module teaches **repeatable checks** and **secure defaults** so your Part 1 cluster behaves like something you could hand to another engineer.

## Outcomes

After this module you should be able to:

- Explain why **large clusters**, **multi-zone**, and **node validation** matter before you add workloads.
- Apply **Pod Security Standards** labels at the namespace level and know where to look when admission blocks a pod.
- Read **PKI layout** on a control-plane node and know when cert rotation is urgent.
- Run a **verify-before-change** habit: nodes → system pods → events → targeted `describe`.

## Before you start

- You need a **working cluster** from [Part 1](../README.md): Minikube, Kind, or kubeadm (local or lab VMs).
- `kubectl` must use the correct context (`kubectl config current-context`).
- **Module readiness (read-only):** from this directory, run:

```bash
bash scripts/verify-1-3-module-readiness.sh
```

## Cross-cutting topics (where to learn them)

This module focuses on **cluster-level** habits. Several “day-2 workload” topics appear again in Part 2 — use the table so you know what 1.3 covers vs what comes next.

| Topic | In this module | Also see |
|--------|----------------|----------|
| **Resource requests & limits** | Namespace **ResourceQuota** and **LimitRange** patterns in [1.1.3 local dev workspace](../1.1-learning-environment/1.1.3-local-development-clusters/README.md) | [Kubernetes workloads concepts](https://kubernetes.io/docs/concepts/workloads/); course **2.4** when lessons are complete |
| **Liveness / readiness probes** | Mentioned in large-cluster and node-readiness context | **2.4 Workloads** (Pods), production runbooks |
| **Security contexts** (runAsUser, capabilities) | **1.3.4** Pod Security Standards (admission-level guardrails) | **2.8 Security** in this course |
| **PodDisruptionBudgets** | **1.3.1** scale and availability mindset | **2.10 Scheduling** when expanded |

For **Kubernetes version skew** and “what we test against,” see [`KUBERNETES_VERSION_MATRIX.md`](../../KUBERNETES_VERSION_MATRIX.md) at the repo root.

## Topics in this module

**Say:**
Five lessons, work them in order. Each one adds a layer of production readiness on top of the last.

```
  1.3.1               1.3.2              1.3.3            1.3.4              1.3.5
  Scale           →   Multi-zone     →   Node         →   Pod Security   →   PKI
  readiness           resilience         validation        Standards          health
```

## Children (work in order)

- [1.3.1 Considerations for large clusters](1.3.1-considerations-for-large-clusters/README.md)
- [1.3.2 Running in multiple zones](1.3.2-running-in-multiple-zones/README.md)
- [1.3.3 Validate node setup](1.3.3-validate-node-setup/README.md)
- [1.3.4 Enforcing Pod Security Standards](1.3.4-enforcing-pod-security-standards/README.md)
- [1.3.5 PKI certificates and requirements](1.3.5-pki-certificates-and-requirements/README.md)

## Module wrap — operational checklist

When you finish **1.3.5**, run the snapshot below on your lab cluster. Use the same pattern after **any** change that touches nodes, CNI, or admission policy.

**What happens when you run this:**  
Wide node list, all pods, then the newest cluster events — a read-only triage picture.

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get events -A --sort-by=.lastTimestamp | tail -n 30
```

**Expected:**

- All nodes `Ready`.
- System pods in `kube-system` (and your app namespaces) stable or clearly intentional (e.g. `Completed` Jobs).
- No repeating `Failed` / `BackOff` / admission errors without a follow-up action.

## Next

Continue to [Part 2: Concepts](../../part-2-concepts/README.md) — run `bash scripts/verify-part2-prerequisites.sh` from `part-2-concepts/` first.
