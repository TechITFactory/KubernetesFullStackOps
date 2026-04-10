# 1.1.2 Kind (Kubernetes in Docker) — teaching transcript

## Intro

This lesson builds a **multi-node Kubernetes cluster** where each node runs as a **Docker container** — that is **Kind** (Kubernetes in Docker). Fast to create, great for **CI-style** workflows and testing scheduling across nodes.

**You need:** Docker running; [Part 0](../../../part-0-prerequisites/README.md)–level terminal comfort. **Kind requires Docker** — no Docker, no Kind.

Replace **`/path/to/K8sOps`** with your clone path.

**Context:** This course names the cluster **`kfsops-kind`**. Most `kubectl` commands below use **`--context kind-kfsops-kind`** so you do not accidentally hit another cluster.

**Note:** If you use **Minikube** instead, skip this lesson and use [1.1.1](../1.1.1-minikube-setup-and-configuration/README.md). Pick one local stack for a clean path through 1.1.3.

---

## Step 1 — Open this lesson in the terminal

**Say:**  
I stand in the lesson folder so scripts and YAML paths resolve.

**Run:**

```bash
cd /path/to/K8sOps/part-1-getting-started/1.1-learning-environment/1.1.2-kind-kubernetes-in-docker
pwd
```

**Expected:**  
Path ending in `1.1.2-kind-kubernetes-in-docker`.

---

## Step 2 — Make scripts executable

**Run:**

```bash
chmod +x scripts/*.sh
```

**Expected:**  
No errors.

---

## Step 3 — Install Kind and kubectl (idempotent)

**Say:**  
Same idea as Minikube’s installer: checks version, skips if already correct. May use `sudo` for `/usr/local/bin`.

**Run:**

```bash
./scripts/install-kind.sh
```

**Expected:**  
`kind version` works; `kubectl version --client` works.

---

## Step 4 — Create the Kind cluster (idempotent)

**Say:**  
The script uses `yamls/kind-cluster-config.yaml` — one control-plane node, one worker, and **host port 8888 → node port 30080** so we can `curl` from the laptop. If the cluster already exists, the script reuses it.

**Run:**

```bash
./scripts/create-kind-cluster.sh
```

**Expected:**  
Cluster created or “already exists”; `kubectl get nodes --context kind-kfsops-kind` shows **two** nodes `Ready` (control-plane + worker).

---

## Step 5 — Apply the sample workload

**Say:**  
This creates namespace `kind-lab`, an `echoserver` Deployment, and a **NodePort** Service on **30080** — matching the Kind config mapping to **localhost:8888** on the host.

**Run:**

```bash
kubectl apply -f yamls/sample-workload.yaml --context kind-kfsops-kind
```

**Expected:**  
Resources created or unchanged.

---

## Step 6 — Wait for the pod, then curl

**Say:**  
Once the pod is ready, traffic from **localhost:8888** should reach the echoserver through the published port mapping.

**Run:**

```bash
kubectl rollout status deployment/echoserver -n kind-lab --context kind-kfsops-kind --timeout=120s
kubectl get pods -n kind-lab -o wide --context kind-kfsops-kind
curl -sS http://localhost:8888/ | head -n 5
```

**Expected:**  
Rollout success; pod `Running`; `curl` returns echo output (HTTP body with request details).

---

## Step 7 — Fast validation

**Run:**

```bash
kubectl get nodes --context kind-kfsops-kind
kubectl get pods -A --context kind-kfsops-kind | head -n 15
curl -sS -o /dev/null -w "%{http_code}\n" http://localhost:8888/
```

**Expected:**  
Two Ready nodes; `kind-lab` pod listed; HTTP **200** (or success code).

---

## Step 8 — Tear down (optional)

**Run:**

```bash
./scripts/teardown.sh
```

**Expected:**  
Kind cluster deleted or already absent.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/install-kind.sh` | Installs `kind` + `kubectl` |
| `scripts/create-kind-cluster.sh` | Creates `kfsops-kind` from config |
| `scripts/teardown.sh` | Deletes cluster |
| `yamls/kind-cluster-config.yaml` | Topology + port mapping |
| `yamls/sample-workload.yaml` | `kind-lab` + NodePort **30080** |
| `yamls/failure-troubleshooting.yaml` | Kind / context / networking hints |

---

## Troubleshooting

- **docker: not found** → start Docker; Kind depends on it
- **port 8888 in use** → change `hostPort` in `kind-cluster-config.yaml` and align Service `nodePort`, or stop the conflicting process
- **wrong cluster** → `kubectl config current-context`; use `--context kind-kfsops-kind` every time
- **Image pull errors** → network / registry access for `registry.k8s.io`
- **Cluster create fails** → `docker info`; WSL2: enough RAM/disk

---

## Learning objective

- Install Kind; create a multi-node cluster from config; apply NodePort workload; verify with `curl`; tear down.

## Why this matters

Kind is the default answer for **throwaway clusters in CI** and for **multi-node** behavior on a laptop.

## Next

[1.1.3 Local development clusters](../1.1.3-local-development-clusters/README.md) — add `dev-local` namespace, quota, and limit range on **this** cluster (keep `kubectl` context on `kind-kfsops-kind`).
