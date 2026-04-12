# 01 Minikube Setup and Configuration — teaching transcript

## Intro

This lesson gives you a **real Kubernetes cluster on your laptop** using **Minikube** — one node, same `kubectl` as production-style clusters, good for learning and add-ons.

**You need:** [Part 0](../../../00-Prerequisites/README.md) (or equivalent terminal + Docker skills); **Docker** (or another Minikube driver you configure). Minikube can use the **Docker driver** (common) or a VM — the scripts default toward Docker-style setups.

**Note:** If you use **Kind** instead, skip this lesson and do [02](../02-kind-kubernetes-in-docker/README.md). Do **not** run both for the same course track unless you know why.

**Teaching tip:** Each step includes **What happens when you run this** before **Run**. Shell scripts document the same behavior in a header comment at the top of each file under `scripts/`.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/01-learning-environment/01-minikube-setup"
```

> If you set `COURSE_DIR` in Part 0, it is still set in your current shell. If you opened a new terminal, set it again and `cd` here.

## Flow of this lesson

```
  [ Step 2 ]     [ Step 3 ]      [ Steps 4–6 ]        [ Step 7 ]       [ Step 8 ]      [ Step 9 ]
  chmod +   →    install CLI  →  start cluster   →   apply + wait  →  open service → recap (opt)
  scripts                        + ingress           smoke test                        tear down
```

**Say:**

We make scripts runnable, install or refresh Minikube and kubectl, start the course profile with ingress, apply the smoke manifest, wait for the Deployment, open the service from the laptop, optionally recap with three read-only gets, and optionally delete the profile when we are done.

---

## Step 1 — Open this lesson in the terminal

**What happens when you run this:**  
`cd` moves into this lesson; `pwd` prints the path — no cluster or Docker changes.

**Say:**  
I work from the lesson directory so `./scripts` and `./yamls` paths work.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/01-learning-environment/01-minikube-setup"
pwd
```

**Expected:**  
Path ending in `01.1-minikube-setup-and-configuration`.

---

## Step 2 — Make scripts executable

**What happens when you run this:**  
`chmod +x scripts/*.sh` sets the execute permission on every script in `scripts/` — filesystem metadata only.

**Say:**  
Shell scripts shipped in a git repo don't always have the execute bit set. This one command fixes all of them in one go — nothing is downloaded or changed on the cluster.

**Run:**

```bash
chmod +x scripts/*.sh
```

**Expected:**  
No errors.

---

## Step 3 — Install Minikube and kubectl (idempotent)

**What happens when you run this:**  
`install-minikube.sh` may download Minikube and kubectl from the network, then `sudo install` them into `/usr/local/bin` (skips if versions already match). See the script header for OS/arch and env vars.

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

**What happens when you run this:**  
`start-minikube.sh` runs `minikube start` for profile `kfsops-minikube` (or reuses if already Running), enables the **ingress** addon, then `kubectl get nodes`. Creates/starts a local VM or Docker-backed node depending on driver.

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

**What happens when you run this:**  
`kubectl apply -f yamls/smoke-test.yaml` sends the manifest to the API server: creates or updates Namespace `minikube-lab`, Deployment `hello-nginx`, and its Service (declarative; safe to re-run).

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

**What happens when you run this:**  
`kubectl rollout status` blocks until the Deployment’s ReplicaSet reports success or times out. `kubectl get pods` lists pod name, phase, and node — read-only after objects exist.

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

**What happens when you run this:**  
`minikube service` starts a tunnel from your host to the cluster Service URL (and may open a browser). Traffic flows host → minikube network → Service → Pod — blocks until you interrupt in some setups.

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

**What happens when you run this:**  
Three read-only `kubectl get` calls: nodes, pods in `minikube-lab`, Services — confirms API and workload state.

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

**What happens when you run this:**  
`teardown.sh` runs `minikube delete` for profile `kfsops-minikube` if it exists — frees CPU/RAM/disk; kubeconfig context for that profile may be removed.

**Say:**  
Teardown deletes the Minikube profile for this course. Idempotent — safe if already deleted.

**Run:**

```bash
./scripts/teardown.sh
```

**Expected:**  
Profile removed or script reports nothing to do.

---

## Troubleshooting

- **`Unable to connect to the server: dial tcp ... connection refused`** → `minikube status`; re-run `./scripts/start-minikube.sh`
- **`ErrImagePull` or `ImagePullBackOff` on hello-nginx** → `kubectl describe pod -n minikube-lab`; fix network, proxy, or registry access
- **`minikube: command not found`** → re-run `./scripts/install-minikube.sh`; ensure `/usr/local/bin` is on `PATH`
- **`Permission denied` running `./scripts/...`** → Step 2 `chmod +x scripts/*.sh`
- **`Exiting due to DRV_NOT_DETECTED` or driver errors** → follow Minikube docs for `docker` vs `virtualbox` / `hyperv` / `kvm2`

---

## Learning objective

- Installed and started Minikube with the course profile; applied the smoke manifest; verified pods and Service; tore down the profile when finished.

## Why this matters

Local clusters are how teams reproduce Kubernetes bugs before staging. Minikube is a common “flight simulator” for real clusters.

## Video close — fast validation

**What happens when you run this:**

Read-only snapshot: nodes wide, pods and Service in `minikube-lab`, cluster info. Skip if you already ran Step 8 in the same take.

**Say:**

I end the segment with a read-only trio plus cluster-info so viewers see Ready nodes and the service row without starting a tunnel.

**Run:**

```bash
kubectl get nodes -o wide
kubectl get pods,svc -n minikube-lab -o wide
kubectl cluster-info
```

**Expected:**

One Ready node; `hello-nginx` pod `Running`; Service row present; `cluster-info` prints control-plane URL.

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

## Next

Continue to [03 Local development clusters](../03-local-development-clusters/README.md) to set up the `dev-local` workspace on this Minikube cluster.
