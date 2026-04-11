# 1.3.3 Validate Node Setup — teaching transcript

- **Summary**: Node validation should happen before `kubeadm join` or workload rollout, not after failures start surfacing.
- **Content**: The script checks swap, sysctls, required binaries, runtime sockets, kernel modules, and kubelet prerequisites.
- **Lab**: Run the validator on a node and fix every failed prerequisite before joining it to a cluster.

## Assets

- `scripts/validate-node-setup.sh`
- `yamls/node-validation-baseline.yaml`
- `yamls/failure-troubleshooting.yaml`

**Teaching tip:** Run `validate-node-setup.sh` **on the Linux node itself** before `kubeadm join`. **WHAT THIS DOES WHEN YOU RUN IT** is in the script header. The script does **not** require a working `kubectl` context — it runs local checks only.

---

## Intro

Here's the scenario that happens more than it should.

You provision a new VM, run `kubeadm join`, and the node joins the cluster. Everything looks fine. Three days later, pods start failing on that node — `OOMKilled`, networking not working, or image pulls hanging. You trace it back and discover swap was enabled, or a required kernel module wasn't loaded, or the CRI socket path was wrong.

These are things a pre-join validation script would have caught in 30 seconds.

`validate-node-setup.sh` is that script. It checks the prerequisites that kubeadm itself assumes are in place — but doesn't verify for you. Think of it as the checklist a pilot runs before takeoff, not after the wheels leave the ground.

---

## Flow of this lesson

**Say:**
Two stages. First run the validator on the node — it either passes or lists specific failures. Then apply the in-cluster baseline manifest to record what a valid node looks like for your cluster.

```
  [ Step 1 ]                  [ Step 2 ]
  Run validate-node-   →      Apply baseline
  setup.sh on the             manifest to
  Linux node                  the cluster
```

---

## Step 1 — Run the node validator

**What happens when you run this:**
`validate-node-setup.sh` runs entirely on the local node — no cluster API needed. It checks:
- **Swap** is disabled (`/proc/swaps` empty or no active swap entries)
- **`br_netfilter` and `overlay` kernel modules** are loaded (required for CNI and container networking)
- **`net.bridge.bridge-nf-call-iptables`** sysctl is set to 1
- **`net.ipv4.ip_forward`** sysctl is set to 1
- **`kubeadm`, `kubelet`, `kubectl`** are on PATH
- **The CRI socket** is present and responsive (containerd, CRI-O, or cri-dockerd)

Each check prints `[PASS]`, `[WARN]`, or `[FAIL]` with a short explanation. Exits non-zero if any `[FAIL]` is found.

**Say:**
I run this before I ever touch `kubeadm join`. Each failure it finds is something that would have caused a confusing problem later. I fix every `[FAIL]` before I continue — warnings are informational.

**Run:**

```bash
./scripts/validate-node-setup.sh
```

**Expected:**
All required checks show `[PASS]`. If anything shows `[FAIL]`, fix it — see the Troubleshooting section below — then re-run until the script exits 0.

---

## What each check means

**Swap disabled:**
Kubernetes expects swap to be off. Kubelet refuses to start with swap enabled by default (you can override with `--fail-swap-on=false` but this is not recommended for production). Disable swap permanently with `swapoff -a` and remove the swap entry from `/etc/fstab`.

**Kernel modules (`br_netfilter`, `overlay`):**
`overlay` is required for the overlay filesystem driver that containers use. `br_netfilter` enables iptables to see bridged traffic — required for Kubernetes networking policies and service routing. Load them with:
```bash
modprobe overlay
modprobe br_netfilter
```
To persist across reboots:
```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```

**Sysctls:**
These two let the kernel forward network traffic through bridge interfaces and between network namespaces — exactly what pod networking needs. Set them with:
```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
```

**CRI socket:**
The validator checks that the socket file exists and the runtime responds to a `crictl info` call. If this fails, the runtime is not running or is at the wrong path — see your runtime's lesson (1.2.1.x) for the correct socket path.

---

## Step 2 — Apply the in-cluster baseline

**What happens when you run this:**
`kubectl apply -f yamls/node-validation-baseline.yaml` creates a ConfigMap in `kube-system` that records what a validated node looks like — swap disabled, modules loaded, sysctls set, CRI socket path. This is documentation stored in the cluster, not live validation.

**Say:**
This baseline is useful for two things: it's a record you can point to during audits ("yes, we validate nodes before joining"), and it's something new team members can read to understand what the cluster expects from each node.

**Run:**

```bash
kubectl apply -f yamls/node-validation-baseline.yaml
```

**Expected:**
ConfigMap created or unchanged.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/validate-node-setup.sh` | Local node prerequisite check — no cluster API required |
| `yamls/node-validation-baseline.yaml` | ConfigMap recording expected node state |
| `yamls/failure-troubleshooting.yaml` | Swap, sysctl, module, and runtime socket fixes |

---

## Troubleshooting

- **Swap active** → `sudo swapoff -a` immediately; remove or comment out the swap line in `/etc/fstab`
- **Module missing** → `sudo modprobe overlay && sudo modprobe br_netfilter`; then add to `/etc/modules-load.d/k8s.conf`
- **Sysctl not set** → run the `sysctl.d/k8s.conf` block above; `sudo sysctl --system` applies immediately
- **CRI socket missing** → service not running or wrong path; check `sudo systemctl status containerd` (or crio / cri-docker) and confirm socket path from your 1.2.1 lesson
- **Script exits 0 but node still NotReady after join** → the validator checks prerequisites, not CNI; if networking is broken after join, check your CNI plugin install

---

## Learning objective

- Run the node validator and interpret its output.
- Fix the six most common node prerequisite failures before `kubeadm join`.
- Explain why swap, kernel modules, and sysctls matter for Kubernetes networking and stability.

## Why this matters

Most "my node joined but something's wrong" situations trace back to one of the items this script checks. Running it before join converts unpredictable failures into predictable ones — you fix them in a controlled window, not in the middle of an incident.

---

## Video close — fast validation

**What happens when you run this:**
Re-validate locally; then read-only `kubectl` summary of the first node's conditions.

**Say:**
The node validator catches pre-join problems. The `describe node` output catches post-join problems — look at the Conditions section for `MemoryPressure`, `DiskPressure`, `PIDPressure`, and `Ready`. All should be `False` except `Ready` which should be `True`.

```bash
./scripts/validate-node-setup.sh
kubectl get nodes -o wide
kubectl describe node "$(kubectl get nodes -o name | head -n 1 | cut -d'/' -f2)" | sed -n '1,40p'
```

---

## Next

[1.3.4 Enforcing Pod Security Standards](../1.3.4-enforcing-pod-security-standards/README.md)
