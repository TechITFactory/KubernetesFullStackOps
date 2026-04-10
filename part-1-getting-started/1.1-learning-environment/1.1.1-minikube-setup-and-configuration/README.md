# 1.1.1 Minikube Setup and Configuration — teaching transcript

## Intro

This lesson gives you a **real Kubernetes cluster on your laptop** using **Minikube** — one node, same `kubectl` as production-style clusters, good for learning and add-ons.

**You need:** [Part 0](../../../part-0-prerequisites/README.md) (or equivalent terminal + Docker skills); **Docker** (or another Minikube driver you configure). Minikube can use the **Docker driver** (common) or a VM — the scripts default toward Docker-style setups.

Replace **`/path/to/K8sOps`** with your clone path. All **`Run`** blocks assume you start from this lesson folder after **Step 1**.

**Note:** If you use **Kind** instead, skip this lesson and do [1.1.2](../1.1.2-kind-kubernetes-in-docker/README.md). Do **not** run both for the same course track unless you know why.

---

## Step 1 — Open this lesson in the terminal

**Say:**  
I work from the lesson directory so `./scripts` and `./yamls` paths work.

**Run:**

```bash
cd /path/to/K8sOps/part-1-getting-started/1.1-learning-environment/1.1.1-minikube-setup-and-configuration
pwd
```

**Expected:**  
Path ending in `1.1.1-minikube-setup-and-configuration`.

---

## Step 2 — Make scripts executable

**Say:**  
Shell scripts need the execute bit before I can run them.

**Run:**

```bash
chmod +x scripts/*.sh
```

**Expected:**  
No errors.

---

## Step 3 — Install Minikube and kubectl (idempotent)

**Say:**  
The install script checks what is already installed — safe to run more than once. It may use `sudo` to place binaries under `/usr/local/bin`.

**Run:**

```bash
./scripts/install-minikube.sh
```

**Expected:**  
Success messages; `minikube version` and `kubectl version --client` work afterward.

---

## Step 4 — Start the Minikube cluster (idempotent)

**Say:**  
The start script uses a **profile** (this course uses `kfsops-minikube`). If the cluster is already running, the script reuses it. Ingress add-on is enabled for later lessons.

**Run:**

```bash
./scripts/start-minikube.sh
```

**Expected:**  
Cluster starts or “already running”; `kubectl get nodes` shows one node `Ready`.

---

## Step 5 — Apply the smoke test (namespace + app + service)

**Say:**  
One manifest creates namespace `minikube-lab`, a Deployment `hello-nginx`, and a Service. This proves scheduling, DNS, and networking.

**Run:**

```bash
kubectl apply -f yamls/smoke-test.yaml
```

**Expected:**  
`namespace/minikube-lab created` (or unchanged), deployment and service created/unchanged.

---

## Step 6 — Wait until the pod is ready

**Say:**  
I wait for the Deployment to roll out before I open the service — otherwise I might hit an empty endpoint.

**Run:**

```bash
kubectl rollout status deployment/hello-nginx -n minikube-lab --timeout=120s
kubectl get pods -n minikube-lab -o wide
```

**Expected:**  
`successfully rolled out`; pod `Running`.

---

## Step 7 — Reach the app from your machine

**Say:**  
`minikube service` opens a tunnel and often launches a browser to the Nginx welcome page. That confirms the full path from laptop → cluster → pod.

**Run:**

```bash
minikube service hello-nginx -n minikube-lab
```

**Expected:**  
URL printed and/or browser shows Nginx; or use the URL with `curl` in another terminal.

---

## Step 8 — Quick validation (optional recap)

**Say:**  
These three commands are my fast health check before moving on.

**Run:**

```bash
kubectl get nodes
kubectl get pods -n minikube-lab -o wide
kubectl get svc -n minikube-lab
```

**Expected:**  
One Ready node; pod Running; `hello-nginx` Service present.

---

## Step 9 — Tear down when you are done (optional)

**Say:**  
Teardown deletes the Minikube profile for this course. Idempotent — safe if already deleted.

**Run:**

```bash
./scripts/teardown.sh
```

**Expected:**  
Profile removed or script reports nothing to do.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/install-minikube.sh` | Installs Minikube + kubectl |
| `scripts/start-minikube.sh` | Starts profile `kfsops-minikube`, enables ingress |
| `scripts/teardown.sh` | Deletes the profile |
| `yamls/smoke-test.yaml` | `minikube-lab` + `hello-nginx` + Service |
| `yamls/failure-troubleshooting.yaml` | Optional cheat sheet (Minikube failures) |

---

## Troubleshooting

- **Cannot connect to cluster** → `minikube status`; re-run `start-minikube.sh`
- **Image pull errors** → network / proxy; check `kubectl describe pod -n minikube-lab`
- **minikube: command not found** → re-run install; check `PATH`
- **Permission denied on scripts** → Step 2 `chmod +x`
- **Driver issues** → see Minikube docs for `docker` vs `virtualbox` / `hyperv`

---

## Learning objective

- Install and start Minikube; apply a manifest; verify pods and service; tear down cleanly.

## Why this matters

Local clusters are how teams reproduce Kubernetes bugs before staging. Minikube is a common “flight simulator” for real clusters.

## Next

Either continue with [1.1.3 Local development clusters](../1.1.3-local-development-clusters/README.md) on this cluster, **or** if you chose Kind instead, open [1.1.2](../1.1.2-kind-kubernetes-in-docker/README.md) and skip this lesson next time.
