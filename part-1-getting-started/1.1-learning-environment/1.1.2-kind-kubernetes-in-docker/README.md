# 1.1.2 Kind (Kubernetes in Docker)

- **Summary**: Install Kind, create a local multi-node Kubernetes cluster entirely inside Docker containers, and validate it with a sample workload accessible on `localhost:8080`.
- **Content**: What Kind is and how it differs from Minikube, multi-node cluster topology, port mapping from host to NodePort, idempotent cluster creation.
- **Lab**: Run `install-kind.sh`, run `create-kind-cluster.sh`, apply `sample-workload.yaml`, reach the echoserver at `localhost:8080`, run `teardown.sh` to clean up.

## Files

| Path | Purpose |
|------|---------|
| `scripts/install-kind.sh` | Idempotent: installs Kind + kubectl, skips if already at target version |
| `scripts/create-kind-cluster.sh` | Idempotent: creates the cluster, reuses it if already exists |
| `scripts/teardown.sh` | Idempotent: deletes the Kind cluster, no-op if already gone |
| `yamls/kind-cluster-config.yaml` | 1 control-plane + 1 worker node; maps NodePort 30080 → host port 8080 |
| `yamls/sample-workload.yaml` | Namespace + Deployment + NodePort Service — validates networking end to end |

## Quick Start

```bash
./scripts/install-kind.sh
./scripts/create-kind-cluster.sh
kubectl apply -f yamls/sample-workload.yaml --context kind-kfsops-kind
curl localhost:8080
./scripts/teardown.sh
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

In the last lesson we used Minikube. It's great for learning — one node, easy addons, browser-friendly.

But here is a problem. Real Kubernetes clusters have multiple nodes — a control-plane that makes decisions, and workers that run your apps. Minikube only simulates one node, so you cannot test certain things: what happens when a worker node goes down, how pods get scheduled across nodes, multi-node networking.

And there is another problem: CI/CD pipelines. When your team pushes code, automated systems need to spin up a Kubernetes cluster in seconds, run tests, then destroy it. Minikube is too heavy for that.

**Kind** solves both. That's what we're setting up today.

---

### [0:45–2:30] What Is Kind?

Kind stands for **Kubernetes IN Docker**.

Here is the idea: normally, a Kubernetes node is an entire server — a physical or virtual machine. Kind fakes it. It runs each Kubernetes node as a **Docker container** on your machine.

So if you ask Kind for a cluster with 1 control-plane and 2 workers, it starts 3 Docker containers. Each one behaves exactly like a real Kubernetes node. They can communicate with each other. Pods get scheduled across them. Network policies work. It is the real thing, just compressed into Docker containers.

**Analogy**: think of a movie set. In a real city, buildings are solid concrete. On a movie set, the buildings are just facades — they look and photograph exactly like real buildings, but they're lightweight and you can build ten of them in a day. Kind is the movie set version of a Kubernetes cluster.

**Kind vs Minikube — when to use which**:

| | Minikube | Kind |
|---|---|---|
| Nodes | 1 (single node) | Multiple (control-plane + workers) |
| Driver | Docker or VM | Docker only |
| Addons | Rich (dashboard, ingress, etc) | Minimal — you install manually |
| Start speed | Moderate (30–60s) | Fast (10–20s) |
| Best for | Local development | CI/CD pipelines, multi-node testing |

Real-world usage: GitHub Actions, GitLab CI, and Jenkins all use Kind to run Kubernetes integration tests. When you open a pull request at a company like Grafana or HashiCorp, Kind spins up a throwaway cluster, runs their test suite, then deletes it. The whole thing takes under a minute.

---

### [2:30–4:00] The Cluster Config YAML

Let's look at `kind-cluster-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kfsops-kind
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30080
        hostPort: 8080
        protocol: TCP
  - role: worker
```

This tells Kind: "give me two nodes — one control-plane, one worker."

The `extraPortMappings` section is how we reach the cluster from our laptop. Here is the chain:

```
Your browser → localhost:8080
             → Kind node container port 30080
             → Kubernetes NodePort Service port 30080
             → echoserver pod port 8080
```

Each arrow is a forwarding step. The `containerPort: 30080` is the Kubernetes NodePort. The `hostPort: 8080` is what you type in your browser. Without this mapping, a NodePort service would be trapped inside Docker with no way out.

This is why we fixed `sample-workload.yaml` to use `type: NodePort` with `nodePort: 30080` — matching this mapping exactly. A ClusterIP service would be unreachable from outside the Docker network.

---

### [4:00–5:30] The Install Script

`install-kind.sh` follows the exact same pattern as `install-minikube.sh`:

```bash
VERSION="${1:-v0.23.0}"
```
Default version pinned. Pass a version number as argument to override. This is important for CI — you want reproducible builds, so you pin the version rather than always pulling "latest".

```bash
if command -v kind >/dev/null 2>&1; then
  CURRENT_KIND="$(kind version ...)"
fi

if [[ "$(normalize_version "$CURRENT_KIND")" == "$(normalize_version "$VERSION")" ]]; then
  echo "Kind already installed. Skipping."
```
Idempotency check. Same pattern as before — check before acting.

```bash
curl -fsSL -o kind "https://kind.sigs.k8s.io/dl/${VERSION}/kind-${OS}-${ARCH}"
sudo install kind "$INSTALL_DIR/kind"
```
Downloads the single Kind binary and installs it. Kind is one small file — no dependencies, no package manager.

---

### [5:30–6:45] The Create Cluster Script

`create-kind-cluster.sh`:

```bash
CLUSTER_NAME="${CLUSTER_NAME:-kfsops-kind}"
CONFIG_PATH="${CONFIG_PATH:-$SCRIPT_DIR/../yamls/kind-cluster-config.yaml}"
```
The cluster name and config are configurable via environment variables. Need a second cluster? `CLUSTER_NAME=my-test ./create-kind-cluster.sh`.

```bash
command -v docker >/dev/null 2>&1 || {
  echo "docker was not found. Kind requires Docker." >&2
  exit 1
}
```
Kind cannot run without Docker. This guard gives a clear error instead of a confusing Docker connection failure later.

```bash
if kind get clusters 2>/dev/null | grep -Fxq "$CLUSTER_NAME"; then
  echo "Kind cluster '$CLUSTER_NAME' already exists. Reusing it."
else
  kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_PATH"
fi
```
Idempotency. `kind get clusters` lists existing clusters. If ours is there, skip creation. This means running `create-kind-cluster.sh` twice is completely safe — it will not try to create a duplicate.

```bash
kubectl cluster-info --context "kind-${CLUSTER_NAME}"
kubectl get nodes --context "kind-${CLUSTER_NAME}"
```
After creating, verify the cluster is reachable and both nodes (`control-plane` and `worker`) show as `Ready`.

---

### [6:45–8:00] Apply the Sample Workload

```bash
kubectl apply -f yamls/sample-workload.yaml --context kind-kfsops-kind
```

This creates three resources:

**Namespace** `kind-lab` — same isolation pattern you saw in 1.1.1. Always use namespaces, never deploy into `default` for lab work.

**Deployment** `echoserver` — runs the `registry.k8s.io/echoserver:1.10` image. Echoserver is a tiny HTTP server that echoes back everything in your request — headers, URL, body. Perfect for verifying that traffic is actually flowing through Kubernetes networking.

**Service** `echoserver` of type `NodePort:30080` — matches the port mapping in our Kind config so traffic from `localhost:8080` reaches the pod.

Wait for the pod:
```bash
kubectl get pods -n kind-lab -w --context kind-kfsops-kind
```

Then test:
```bash
curl localhost:8080
```

You will see the echoserver echo back your HTTP request details. That proves the full chain is working: host → Docker → Kind node → NodePort → pod.

---

### [8:00–9:30] Real World — CI/CD with Kind

Here is a real GitHub Actions workflow that uses Kind:

```yaml
- name: Create Kind cluster
  uses: helm/kind-action@v1
  with:
    cluster_name: test-cluster

- name: Deploy app
  run: kubectl apply -f k8s/

- name: Run integration tests
  run: ./tests/run.sh
```

Every time someone opens a pull request, GitHub spins up a fresh Kind cluster, deploys the app, runs tests, and destroys the cluster. The whole thing takes about 90 seconds. If tests fail, the PR is blocked. If they pass, the code merges.

This is the real value of Kind: disposable clusters. You create one, use it, destroy it. No cleanup, no shared state, no "it works on my machine" — everyone runs the same cluster config from the same YAML file.

Companies like Kubernetes itself (yes, Kubernetes uses Kind to test Kubernetes), Flux, ArgoCD, and Helm all use Kind in their CI pipelines.

---

### [9:30–10:00] Recap

- **Kind** = Kubernetes nodes running as Docker containers — lightweight, fast, multi-node.
- **kind-cluster-config.yaml** defines the node topology and the host port mapping that makes NodePort services reachable from your laptop.
- **install-kind.sh** is idempotent — checks version before downloading.
- **create-kind-cluster.sh** is idempotent — reuses an existing cluster, never duplicates.
- **sample-workload.yaml** uses NodePort:30080 to match the port mapping — ClusterIP would be unreachable.
- **teardown.sh** deletes the cluster cleanly, no-op if already gone.

Clean up:

```bash
./scripts/teardown.sh
```

Next: 1.1.3 — Local Development Clusters, where we set up a proper workspace namespace with quotas and defaults on whichever cluster you just created.
