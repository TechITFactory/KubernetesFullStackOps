# Configuration — teaching transcript

## Intro

**Configuration** on Kubernetes is how you inject **settings** and **credentials** without baking them into images, and how you declare **health** and **capacity** so the platform can schedule and restart workloads safely. **ConfigMaps** hold non-secret key/value or file data; **Secrets** hold sensitive bytes (still **base64-encoded at rest** in etcd—**encryption at rest** and **RBAC** complete the story). **Liveness**, **readiness**, and **startup** probes connect application health to **kubelet** decisions: restarts, **Service** endpoints, and slow-boot protection. **Requests** and **limits** for **CPU** and **memory** drive **scheduling**, **QoS**, and **eviction**. **kubeconfig** files organize **clusters**, **users**, and **contexts** for **`kubectl`** and automation. **Windows** nodes have different **resource** accounting surfaces—treat that lesson as hybrid-cluster ops.

**Prerequisites:** [02-Core-Workloads entry](../README.md); [2.6 Storage](../06-storage/README.md) optional (volumes reference ConfigMaps and Secrets).

## Flow of this lesson

```
  ConfigMap + Secret (data in API)
              │
              ▼
  env / volumeMount / projected into Pods
              │
              ▼
  Probes (liveness / readiness / startup)
              │
              ▼
  resources.requests | limits  +  kubeconfig (who accesses API)
```

**Say:**

I teach **ConfigMap before Secret** so learners separate “rotate config” from “rotate credentials”—different runbooks.

## Learning objective

- Follow **2.7.1–2.7.6** from cluster configuration data through probes, sizing, client config, and Windows notes.
- Apply notes YAMLs and **inspect** scripts where present; use **`kubectl explain`** for field truth on your server version.

## Why this matters

Misconfigured **readiness** takes pods out of **Services** silently; wrong **limits** cause **CPU throttling** and **OOM**; broken **kubeconfig** blocks every incident response.

## Children (suggested order)

1. [2.7.1 ConfigMaps](01-configmaps/README.md)
2. [2.7.2 Secrets](02-secrets/README.md)
3. [2.7.3 Liveness, Readiness, and Startup Probes](03-liveness-readiness-and-startup-probes/README.md)
4. [2.7.4 Resource Management for Pods and Containers](04-resource-management-for-pods-and-containers/README.md)
5. [2.7.5 Organizing Cluster Access Using kubeconfig Files](05-organizing-cluster-access-using-kubeconfig-files/README.md)
6. [2.7.6 Resource Management for Windows Nodes](06-resource-management-for-windows-nodes/README.md)

## Module wrap — quick validation

**What happens when you run this:** Read-only snapshot of configuration objects, probe-bearing pods, and client context.

**Say:**

I run this at the start of a recording block to prove which **namespace** holds demo ConfigMaps and whether **current-context** is correct.

```bash
kubectl get configmaps -A 2>/dev/null | head -n 25
kubectl get secrets -A 2>/dev/null | head -n 20
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{"\t"}{.spec.containers[0].readinessProbe}{"\n"}{end}' 2>/dev/null | head -n 15 || true
kubectl config get-contexts
kubectl config current-context
```

## Troubleshooting

- **Empty ConfigMap/Secret lists** → RBAC **list** scoped to namespaces; widen or use `-n`
- **Cannot decode Secret with `kubectl get secret -o yaml`** → **base64** decode locally; prefer **`kubectl get secret … -o jsonpath='{.data.key}'`**
- **Probes missing in jsonpath** → multi-container pods—use **`kubectl describe pod`**
- **Wrong cluster** → **`kubectl config get-contexts`** and **`use-context`**
- **`kubeconfig` merge surprises** → **`KUBECONFIG`** env lists multiple files—know precedence

## Next

[2.8 Security](../08-security/README.md)
