# 02 Kind (Kubernetes in Docker) — teaching transcript

## Intro

This lesson builds a **multi-node Kubernetes cluster** where each node runs as a **Docker container** — that is **Kind** (Kubernetes in Docker). Fast to create, great for **CI-style** workflows and testing scheduling across nodes.

**You need:** Docker running; [Part 0](../../../00-Prerequisites/README.md)–level terminal comfort. **Kind requires Docker** — no Docker, no Kind.

**Context:** This course names the cluster **`kfsops-kind`**. Most `kubectl` commands below use **`--context kind-kfsops-kind`** so you do not accidentally hit another cluster.

**Note:** If you use **Minikube** instead, skip this lesson and use [01](../01.1-minikube-setup-and-configuration/README.md). Pick one local stack for a clean path through 03.

**Teaching tip:** Each step includes **What happens when you run this** before **Run**. Shell scripts document the same behavior in a header comment at the top of each file under `scripts/`.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/01-learning-environment/02-kind-in-docker"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 2 ]      [ Step 3 ]       [ Step 4 ]         [ Step 5 ]        [ Step 6 ]       [ Step 7 ]      [ Step 8 ]
  chmod +    →    install kind  →  create cluster  →  apply workload →  wait + curl →  read-only     →  tear down
  scripts                          kfsops-kind         sample YAML        NodePort        recap           (optional)
```

**Say:**

We make scripts executable, install Kind and kubectl if needed, create or reuse the `kfsops-kind` cluster, apply the sample workload, wait for rollout and curl through the published host port, run a short read-only recap, then optionally delete the cluster.

---

## Step 1 — Open this lesson in the terminal

**What happens when you run this:**  
`cd` into the lesson; `pwd` confirms path — no cluster created yet.

**Say:**  
I work from the lesson folder so scripts and YAML paths resolve correctly. `pwd` just confirms we're in the right place.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/01-learning-environment/02-kind-in-docker"
pwd
```

**Expected:**  
Path ending in `01.2-kind-kubernetes-in-docker`.

---

## Step 2 — Make scripts executable

**What happens when you run this:**  
`chmod +x scripts/*.sh` marks course scripts executable — metadata only.

**Say:**  
Same as every lesson — git doesn't always preserve the execute bit. One command, all scripts in this folder are fixed.

**Run:**

```bash
chmod +x scripts/*.sh
```

**Expected:**  
No errors.

---

## Step 3 — Install Kind and kubectl (idempotent)

**What happens when you run this:**  
`install-kind.sh` downloads `kind` and optionally `kubectl` to `/usr/local/bin` with `sudo` when versions differ — see script header for defaults and `SKIP_KUBECTL`.

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

**What happens when you run this:**  
`create-kind-cluster.sh` runs `kind create cluster` with `kind-cluster-config.yaml` (or skips if `kfsops-kind` exists), then `kubectl cluster-info` / `get nodes` on context `kind-kfsops-kind`. Creates Docker “node” containers and installs Kubernetes inside them.

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

**What happens when you run this:**  
`kubectl apply ... --context kind-kfsops-kind` creates/updates Namespace `kind-lab`, Deployment `echoserver`, and NodePort Service (port **30080** on nodes, mapped to host **8888** per Kind config).

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

**What happens when you run this:**  
`rollout status` waits for the Deployment; `get pods` shows placement; `curl` to `localhost:8888` hits the host-mapped NodePort → Service → Pod (HTTP body is the echo response).

**Say:**  
I wait for the rollout first — if I curl before the pod is ready I'll get a connection refused and think something broke. Once the rollout succeeds I check pod placement with `get pods -o wide`, then curl to confirm the full path from my laptop through the Kind port mapping to the container is working.

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

**What happens when you run this:**  
Read-only: node list, short pod list across namespaces, HTTP status code probe to `:8888` — no object changes.

**Say:**

I double-check nodes, sample pods, and an HTTP status code on the mapped host port before calling the lesson done — still no writes to the API.

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

**What happens when you run this:**  
`teardown.sh` runs `kind delete cluster` for `kfsops-kind` if present — removes node containers and Kind’s kubeconfig entry for that cluster.

**Say:**

Deleting the Kind cluster frees Docker CPU and memory; the script is safe to re-run when the cluster is already gone.

**Run:**

```bash
./scripts/teardown.sh
```

**Expected:**  
Kind cluster deleted or already absent.

---

## Troubleshooting

- **`docker: command not found`** → start Docker Desktop or the Linux daemon; Kind requires Docker
- **`bind: address already in use` on port 8888** → edit `hostPort` in `yamls/kind-cluster-config.yaml`, align Service `nodePort`, recreate the cluster, or stop the conflicting host process
- **`kubectl` hits the wrong cluster** → `kubectl config current-context`; add `--context kind-kfsops-kind` to every command in this lesson
- **`Failed to pull image` for Kubernetes or pause images** → check outbound network and registry allow lists for `registry.k8s.io`
- **`ERROR: failed to create cluster`** → `docker info`; on WSL2 allocate enough RAM/disk to Docker

---

## Learning objective

- Installed Kind; created the multi-node `kfsops-kind` cluster from config; applied the NodePort workload; verified with `curl`; deleted the cluster when finished.

## Why this matters

Kind is the default answer for **throwaway clusters in CI** and for **multi-node** behavior on a laptop.

## Video close — fast validation

**What happens when you run this:**

Read-only checks on the Kind context: nodes, a slice of pods, HTTP status on `:8888`.

**Say:**

This is the same recap as Step 7 — I use it as the closing beat so the camera sees green checks without re-applying YAML.

**Run:**

```bash
kubectl get nodes --context kind-kfsops-kind
kubectl get pods -A --context kind-kfsops-kind | head -n 15
curl -sS -o /dev/null -w "%{http_code}\n" http://localhost:8888/
```

**Expected:**

Two Ready nodes; pods listed; HTTP **200**.

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

## Next

[03 Local development clusters](../03-local-development-clusters/README.md) — add `dev-local` namespace, quota, and limit range on **this** cluster (keep `kubectl` context on `kind-kfsops-kind`).
