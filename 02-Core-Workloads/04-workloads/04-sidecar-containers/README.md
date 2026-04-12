# Sidecar Containers — teaching transcript

## Intro

A **sidecar** is a container that **runs alongside** the main workload in the **same Pod**, sharing the **network namespace** (loopback between containers) and **volumes** (emptyDir, config mounts). Sidecars implement **cross-cutting** concerns: **log shipping**, **Envoy** or other **proxies**, **config reloaders**, or small **health** helpers. Since Kubernetes **1.29**, **native sidecar** containers use **`restartPolicy: Always`** on an init-style container so the sidecar starts before app containers and **restarts** if it exits—check your cluster version before relying on that field. Without **resource requests and limits**, a noisy sidecar can **starve** the main container for CPU or memory on the same cgroup boundary.

**Prerequisites:** [2.4.1.2 Init Containers](../03-init-containers/README.md) recommended.

## Flow of this lesson

```
  Pod
   ├── main container (app)
   └── sidecar container (helper)  ── shares network + volumes
```

**Say:**

Sidecars trade **deployment independence** for **low latency** IPC and shared disk—too many sidecars is a design smell.

## Learning objective

- Explain the **sidecar pattern** and what is shared with the main container.
- Describe **native sidecars** (`restartPolicy: Always`, 1.29+) at a high level.
- Name common use cases and **resource starvation** risk without limits.

## Why this matters

Platform charts often inject sidecars; unexplained CPU throttling is frequently the sidecar, not the app.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/04-workloads/04-sidecar-containers" 2>/dev/null || cd .
```

## Step 1 — Apply and confirm multiple containers

**What happens when you run this:**

The Pod becomes **Ready** when all containers pass their readiness (if any); this demo typically runs simple sleepers.

**Say:**

I read container **names** from jsonpath so the audience sees **two** processes in one Pod.

**Run:**

```bash
kubectl apply -f yamls/sidecar-demo.yaml
kubectl wait --for=condition=Ready pod/sidecar-demo --timeout=120s
kubectl get pod sidecar-demo -o jsonpath='{.spec.containers[*].name}{"\n"}'
```

**Expected:** Pod `Ready` with multiple container names listed (sidecar pattern visible in spec).

---

## Step 2 — Wide status and combined logs

**What happens when you run this:**

`kubectl logs --all-containers` multiplexes recent lines from each container—useful for quick demos.

**Say:**

In production I still prefer **per-container** logs with `-c` for clarity.

**Run:**

```bash
kubectl get pod sidecar-demo -o wide
kubectl logs sidecar-demo --all-containers=true --tail=20
```

**Expected:** Both containers contributing lines or clean sleep loops; `READY` reflects all containers.

## Video close — fast validation

```bash
kubectl get pod sidecar-demo -o jsonpath='{.spec.containers[*].name}{"\n"}'
kubectl get pod sidecar-demo -o wide
```

## Troubleshooting

- **`READY 1/2`** → one container not ready; `kubectl describe` for probe or crash reasons
- **Sidecar OOMKills app** → set **requests/limits** on **every** container in the Pod
- **Native sidecar ignored** → cluster older than 1.29 or feature not enabled; validate server version
- **Port conflict on localhost** → two containers bind same port in shared network namespace
- **Volume permission issues** → sidecar and app UIDs differ; align **securityContext** or `fsGroup`
- **Image pull only on one container** → `describe` shows which `container` failed

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/sidecar-demo.yaml` | Main + sidecar containers |
| `yamls/failure-troubleshooting.yaml` | Multi-container startup and probe drills |

## Cleanup

```bash
kubectl delete -f yamls/sidecar-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.1.4 Ephemeral Containers](../05-ephemeral-containers/README.md)
