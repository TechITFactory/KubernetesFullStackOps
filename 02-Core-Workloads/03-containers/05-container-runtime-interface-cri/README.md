# Container Runtime Interface (CRI) — teaching transcript



## Intro



**CRI** (Container Runtime Interface) is the **gRPC API** kubelet uses to talk to a pluggable runtime. It exists so Kubernetes does not hard-code Docker or any single vendor: **containerd** and **CRI-O** are common **CRI implementations**; older paths used **cri-dockerd** as a shim. Kubelet sends “create sandbox,” “pull image,” “start container,” and status probes over CRI; the runtime does the OCI work underneath. When pods fail to start with **runtime** errors, operators often SSH to the node and use **`crictl`** against the same Unix socket kubelet uses — that is why Part 1 stressed socket paths and cgroup alignment. This lesson runs a local socket scan script when you are on a node, and drops a **ConfigMap** of notes into the cluster when RBAC allows.



**Prerequisites:** [Part 1](../../../01-Local-First-Operations/README.md).



**Teaching tip:** Run **`inspect-cri-endpoint.sh` on a cluster node** (SSH / cloud node session). From kubectl-only laptop it may print **no sockets** — that is expected.



## One-time setup



```bash

COURSE_DIR="$HOME/K8sOps"

cd "$COURSE_DIR/02-Core-Workloads/03-containers/05-container-runtime-interface-cri"

```



> If you set `COURSE_DIR` earlier, skip the export and just `cd`.



## Flow of this lesson



```

  chmod + inspect script (on node: finds socket + crictl)  →  apply CRI notes ConfigMap

              │                                                    │

              └────────────────────┬───────────────────────────────┘

                                 ▼

                        kubectl get nodes (API view)

```



**Say:**



On a real node the script proves which socket answers; from kubectl I show cluster nodes as the consumer of every CRI-backed pod.



---



## Step 1 — Make the inspect script executable and run it



**What happens when you run this:**



`chmod +x scripts/*.sh` sets execute bits. `./scripts/inspect-cri-endpoint.sh` searches common **Unix socket** paths; if `crictl` exists it may run **`crictl info`** against the first socket found — often requires **`sudo`** on the node. From a laptop without container sockets, output may be warnings only.



**Say:**



CRI is **gRPC over a Unix socket** — containerd and CRI-O each document their default paths. **crictl** is the operator-facing CLI that speaks CRI for debugging pulls, sandboxes, and containers.



**Run:**



```bash

cd "$COURSE_DIR/02-Core-Workloads/03-containers/05-container-runtime-interface-cri"

chmod +x scripts/*.sh

./scripts/inspect-cri-endpoint.sh

```



**Expected:**



On a Linux node with a runtime: a “Found CRI socket” style line and optional JSON from `crictl info`. On a dev laptop: clear message that no socket was found.



If you see `permission denied`, re-run with `sudo`:



```bash

sudo ./scripts/inspect-cri-endpoint.sh

```



---



## Step 2 — Apply CRI notes ConfigMap (optional if RBAC allows)



**What happens when you run this:**



`kubectl apply -f yamls/cri-notes.yaml` creates or updates ConfigMap **`cri-notes`** in **`kube-system`** — documentation payload, not live runtime state.



**Say:**



On managed clusters, writes to **kube-system** often return **Forbidden**; skip this step or change the manifest namespace to one you own — the lesson content is the same.



**Run:**



```bash

kubectl apply -f yamls/cri-notes.yaml

```



**Expected:**



ConfigMap created or unchanged, or `Forbidden` on restrictive clusters.



---



## Step 3 — View cluster nodes from the API



**What happens when you run this:**



`kubectl get nodes -o wide` lists nodes kubelet registers — read-only.



**Say:**



Every **Ready** node is running kubelet with a CRI endpoint; workload pods are implemented as OCI containers behind that boundary.



**Run:**



```bash

kubectl get nodes -o wide

```



**Expected:**



Node list with versions and addresses as your cluster provides.



---



## Troubleshooting



- **No socket found from laptop** → run the script on a **node** SSH session, not the kubectl workstation

- **`crictl: cannot connect to endpoint`** → wrong `--runtime-endpoint`; compare with kubelet config and Part **1.2.1** runtime lesson

- **`Forbidden` applying `cri-notes.yaml`** → edit namespace to `default` or skip apply; read YAML from git

- **kubelet `NotReady` with runtime errors** → `journalctl -u kubelet` on the node; align cgroup driver between kubelet and runtime

- **Docker-only mental model** → Kubernetes 1.24+ uses CRI, not dockershim; point debugging at containerd/CRI-O sockets

- **`sudo` required for `crictl info`** → normal on locked-down nodes; use root or `sudo` per org policy



---



## Learning objective



- Described **CRI** as the gRPC boundary between **kubelet** and **containerd** / **CRI-O** (and why vendor independence matters).

- Ran **inspect-cri-endpoint.sh** and interpreted socket discovery versus `crictl info` output on a node.

- Related **crictl** to operator debugging of image pull and sandbox issues.



## Why this matters



Half of “kubelet says runtime error” tickets clear once someone confirms the correct socket, cgroup driver, and a live `crictl info`. This lesson names that workflow explicitly.



## Video close — fast validation



**What happens when you run this:**



Nodes wide and the first chunk of **kube-system** pods — read-only snapshot of control-plane add-ons that sit beside the runtime on nodes.



**Say:**



I close with nodes plus a slice of kube-system because CNI and runtime daemons show up there in conversation even when the control plane is managed.



**Run:**



```bash

kubectl get nodes -o wide

kubectl get pods -n kube-system -o wide | head -n 15

```



**Expected:**



Nodes listed; first system pods shown.



---



## Repo files (reference)



| Path | Purpose |

|------|---------|

| `scripts/inspect-cri-endpoint.sh` | Local socket scan + optional `crictl info` |

| `yamls/cri-notes.yaml` | In-cluster CRI notes (kube-system) |

| `yamls/failure-troubleshooting.yaml` | Socket / crictl / kubelet alignment |



---



## Cleanup



**What happens when you run this:**



Removes the `cri-notes` ConfigMap from **kube-system** if present. `--ignore-not-found` and `|| true` keep cleanup idempotent.



**Say:**



I delete the notes ConfigMap when the lab is over; missing objects do not fail the shell.



**Run:**



```bash

kubectl delete configmap cri-notes -n kube-system --ignore-not-found 2>/dev/null || true

```



**Expected:**



ConfigMap removed or delete ignored.



---



## Next



[2.4 Workloads](../../04-workloads/README.md)

