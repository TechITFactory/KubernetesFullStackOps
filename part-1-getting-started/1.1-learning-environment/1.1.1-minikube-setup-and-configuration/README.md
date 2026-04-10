# 1.1.1 Minikube Setup and Configuration

- **Summary**: Install Minikube and `kubectl`, start a local single-node Kubernetes cluster, and validate it with a smoke-test workload.
- **Content**: What Minikube is and why it exists, how the install and start scripts work, idempotency in setup automation, smoke-testing a cluster.
- **Lab**: Run `install-minikube.sh`, run `start-minikube.sh`, apply `smoke-test.yaml`, access the service, run `teardown.sh` to clean up.

## Files

| Path | Purpose |
|------|---------|
| `scripts/install-minikube.sh` | Idempotent: installs Minikube + kubectl, skips if already at target version |
| `scripts/start-minikube.sh` | Idempotent: starts the cluster, skips if already running, enables ingress addon |
| `scripts/teardown.sh` | Idempotent: deletes the Minikube profile, no-op if already gone |
| `yamls/smoke-test.yaml` | Namespace + Deployment + Service — validates the cluster end to end |

## Quick Start

```bash
./scripts/install-minikube.sh
./scripts/start-minikube.sh
kubectl apply -f yamls/smoke-test.yaml
minikube service hello-nginx -n minikube-lab
./scripts/teardown.sh
```

## Expected output

- `kubectl get nodes` shows one node in `Ready`.
- Pods in namespace `minikube-lab` reach `Running` after `kubectl apply`.
- Service is reachable (browser or `curl` via `minikube service` / port-forward as in the lab).

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

Welcome to lesson 1.1.1. By the end of the next ten minutes, you will have a fully working Kubernetes cluster running on your laptop — not a pretend version, not a web simulator, an actual cluster you can deploy apps to, break things, fix things, and learn from.

No cloud account needed. No credit card. No waiting for infrastructure. Let's go.

---

### [0:45–2:30] What Is Kubernetes? (In 60 Seconds)

Before we touch Minikube, you need to know — in the simplest possible terms — what Kubernetes actually is.

Imagine you run a pizza restaurant. At lunch, you need 10 chefs. At 3am, you need zero. And if a chef gets sick mid-shift, someone has to cover. You need a manager who watches all of this, adjusts the headcount, and replaces sick chefs automatically.

Kubernetes is that manager — but for software. Instead of chefs, it manages **containers** — small packages of software that run your applications. Kubernetes decides where to run them, restarts them if they crash, adds more when traffic spikes, and removes them when they are not needed.

Real Kubernetes clusters run on multiple powerful servers in data centres at companies like Spotify, Airbnb, and GitHub. They are not something you spin up on a laptop.

So how do you learn it?

---

### [2:30–3:30] What Is Minikube?

**Minikube** is a version of Kubernetes that fits on your laptop. It squishes an entire cluster — normally spread across many machines — into a single virtual machine or Docker container on your local computer.

Think of it like a **flight simulator**. A real passenger jet costs $200 million and needs a runway. A flight simulator costs a fraction of that, fits in a room, and teaches you everything you need to know before you ever touch the real thing.

Minikube is your flight simulator.

It supports:
- The same `kubectl` commands you use on real clusters
- Add-ons like Ingress, the Kubernetes Dashboard, and metrics
- Multiple Kubernetes versions so you can test compatibility

What it is NOT good for: running production workloads. It is a single node — no high availability, no real resource isolation. The moment you want production, you graduate to a real cluster (covered in Part 1.2).

**Real-world usage**: Every Kubernetes engineer on a dev team runs some kind of local cluster for rapid testing before pushing changes to staging or production. Minikube is the most popular choice for developers because of its addon ecosystem.

---

### [3:30–5:00] The Install Script — Line by Line

Let's look at `install-minikube.sh`.

```bash
VERSION="${1:-latest}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
```
These are environment variables with defaults. If you run the script with no arguments, it installs the latest Minikube. If you want a specific version: `VERSION=v1.32.0 ./install-minikube.sh`. This is how you make scripts flexible without hardcoding values.

```bash
detect_os() { ... }
detect_arch() { ... }
```
The script figures out your operating system (Linux or Mac) and CPU architecture (x86 or ARM) automatically. The same script works on your Intel Mac, your M1 Mac, and a Linux server.

```bash
if command -v minikube >/dev/null 2>&1; then
  CURRENT_MINIKUBE="$(minikube version --short ...)"
fi

if [[ "$(normalize_version "$CURRENT_MINIKUBE")" == "$(normalize_version "$VERSION")" ]]; then
  echo "Minikube already installed. Skipping."
```
This is **idempotency**. Before downloading anything, the script checks if the right version is already installed. If yes, it skips. Run this script ten times — it downloads Minikube exactly once. This is a critical property for automation: safe to run again without causing damage or doing unnecessary work.

```bash
curl -fsSL -o minikube "https://storage.googleapis.com/minikube/releases/..."
sudo install minikube "$INSTALL_DIR/minikube"
```
Downloads the binary and installs it system-wide. The same idempotency logic protects `kubectl` installation right below this.

---

### [5:00–6:30] The Start Script — Line by Line

`start-minikube.sh` does the same idempotency trick for the cluster itself.

```bash
PROFILE="${PROFILE:-kfsops-minikube}"
```
A Minikube **profile** is like a named saved cluster. You can have multiple profiles for different projects. We always use `kfsops-minikube` for this course so scripts stay consistent.

```bash
if minikube profile list -o json >/tmp/minikube-profiles.json 2>/dev/null; then
  CURRENT_STATUS="$(... | grep Status ...)"
fi

if [[ "$CURRENT_STATUS" == "Running" ]]; then
  echo "Already running. Reusing it."
```
Before starting, the script checks if the profile already exists and is running. If you call this script again after the cluster is already up, it reuses the existing cluster instead of trying to create a duplicate.

```bash
minikube start \
  --driver="$DRIVER" \
  --cpus="$CPUS" \
  --memory="$MEMORY_MB" \
  --kubernetes-version="$KUBERNETES_VERSION" \
  --profile="$PROFILE"
```
This is the actual start command. `--driver=docker` means Minikube runs inside Docker instead of a full VM — faster to start, lighter on memory. If you prefer a VM, set `DRIVER=virtualbox`.

```bash
minikube addons enable ingress --profile "$PROFILE"
```
Enables the Ingress controller — needed for later lessons where we route HTTP traffic by hostname.

---

### [6:30–8:00] Smoke Test — Validate the Cluster

With the cluster running, apply the smoke test:

```bash
kubectl apply -f yamls/smoke-test.yaml
```

`smoke-test.yaml` creates three things in a single file:

- **Namespace** `minikube-lab` — an isolated workspace so the test doesn't pollute the default namespace.
- **Deployment** `hello-nginx` — one pod running Nginx. Includes CPU and memory limits so it behaves like production workloads.
- **Service** `hello-nginx` of type ClusterIP — exposes the pod inside the cluster.

Wait for the pod:

```bash
kubectl get pods -n minikube-lab -w
```

You will see `STATUS` go from `ContainerCreating` → `Running`. Once it is `Running`, expose it locally:

```bash
minikube service hello-nginx -n minikube-lab
```

Minikube opens a tunnel and your browser loads the Nginx welcome page. The cluster is working end to end — networking, DNS, pod scheduling, everything.

---

### [8:00–9:30] Real World — Where This Is Used

When you join a company that uses Kubernetes, Day 1 your laptop setup will include a local cluster. Here is what that looks like in the real world:

**Developer workflow**: Write code → build Docker image → `kubectl apply` to local cluster → test → push to git → CI/CD deploys to staging.

Minikube fits the first three steps. It lets you catch Kubernetes configuration errors — wrong environment variables, missing secrets, wrong port numbers — before they reach shared environments.

**Add-ons in practice**: The `ingress` addon we enabled mirrors what production clusters use. When you write an Ingress manifest here, the exact same manifest works on a cloud cluster with minimal changes.

**Version testing**: Minikube lets you pin a Kubernetes version. If production runs v1.29, you run `--kubernetes-version=v1.29` locally and catch API deprecation warnings before they hit production.

Companies that use Minikube for local dev: Google (internal Kubernetes teams), Red Hat, VMware, and effectively every team that ships software on Kubernetes.

---

### [9:30–10:00] Recap

Here is what we covered:

- **Kubernetes** manages containers the way a restaurant manager manages chefs — automatic, self-healing, scalable.
- **Minikube** is a single-node Kubernetes cluster that runs on your laptop inside Docker or a VM.
- **install-minikube.sh** is idempotent — checks before downloading, safe to run multiple times.
- **start-minikube.sh** is idempotent — reuses a running cluster, never starts a duplicate.
- **smoke-test.yaml** proves the cluster works: namespace → deployment → pod → service → browser.
- **teardown.sh** deletes the profile cleanly when you are done.

Clean up:

```bash
./scripts/teardown.sh
```

Next: 1.1.2 — Kind (Kubernetes in Docker), which is better suited for multi-node simulation and CI pipelines.

## Video close — fast validation

```bash
kubectl get nodes
kubectl get pods -n minikube-lab -o wide
kubectl get svc -n minikube-lab
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common Minikube setup/runtime failures, checks, and fixes.
