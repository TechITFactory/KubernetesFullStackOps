# 2.4.5 Autoscaling Workloads — teaching transcript

## Intro

Autoscaling in Kubernetes is **layered**. **Horizontal Pod Autoscaler (HPA)** changes **replica counts** on a scalable workload when **metrics** cross thresholds—it answers “need more pods?” **Vertical Pod Autoscaler (VPA)** adjusts **CPU/memory requests** (and can evict pods to apply changes)—it answers “each pod the wrong size?” **Cluster Autoscaler** (cluster add-on, not covered in depth here) adds or **removes nodes** when pods cannot schedule— it answers “need more capacity?” Each layer solves a **different** problem; they **compose** in real platforms but **conflict** if two controllers fight the same dimension—**HPA + VPA on CPU simultaneously** on the same workload is **unsupported** and causes thrash.

**Prerequisites:** [2.4.3.1 Deployments](../2.4.3-workload-management/2.4.3.1-deployments/README.md); [2.4.4 Managing Workloads](../2.4.4-managing-workloads/README.md) recommended.

## Flow of this lesson

```
  Metrics + requests correct?
        │
        ├── HPA ──► replica count
        ├── VPA ──► per-pod requests (recommend or mutate)
        └── Cluster Autoscaler ──► node count (when unschedulable)
```

**Say:**

If metrics are wrong, HPA is a random number generator—**metrics-server** (or vendor equivalent) is prerequisite homework.

## Learning objective

- Name the three autoscaling **layers** and what each adjusts.
- Explain why **HPA + VPA** must not target the **same resource dimension** naïvely.

## Why this matters

Teams enable every autoscaler in the marketplace and then spend weeks debugging oscillating replicas and evictions.

## Children

- [2.4.5.1 Horizontal Pod Autoscaling](2.4.5.1-horizontal-pod-autoscaling/README.md)
- [2.4.5.2 Vertical Pod Autoscaling](2.4.5.2-vertical-pod-autoscaling/README.md)

## Module wrap — quick validation

**Say:**

`kubectl top` failing is your cue that **CPU HPA** will also be blind.

```bash
kubectl get hpa -A 2>/dev/null || true
kubectl api-resources | grep -i verticalpodautoscaler || true
kubectl top pods -A 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **No metrics** → install **metrics-server** (example: `minikube addons enable metrics-server`)
- **HPA `unknown`** → check **metrics API** and **target** reference
- **VPA CRD missing** → install VPA controller for your environment before demos
- **Replicas fight** → ensure only one controller owns **replicas** field
- **`kubectl top` forbidden** → RBAC to **metrics.k8s.io**

## Next

[2.5 Services, Load Balancing, and Networking](../2.5-services-load-balancing-and-networking/README.md)
