# 1.3.3 Validate Node Setup — teaching transcript

## Intro

Here is the scenario that happens more than it should.

You provision a new VM, run `kubeadm join`, and the node shows up. Days later pods on that node fail — swap pressure, bridged traffic missing iptables rules, or the CRI socket path never matched what kubelet expects.

Those failures are what `validate-node-setup.sh` catches **before** join. It checks **swap off**, **`br_netfilter` and `overlay` modules**, **`net.bridge.bridge-nf-call-iptables`**, **`net.ipv4.ip_forward`**, core binaries on `PATH`, and a responsive **CRI socket** (containerd, CRI-O, or cri-dockerd depending on your prior lesson).

**Teaching tip:** Run `validate-node-setup.sh` **on the Linux node itself** as a user who can read `/proc` and run `sudo` where the script requires it. See the script header for details.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-1-getting-started/1.3-best-practices/1.3.3-validate-node-setup"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]                  [ Step 2 ]                 [ Step 3 ]
  Copy or run script    →     Fix any FAIL lines    →     Apply baseline
  on target Linux node        (swap, modules,          ConfigMap (optional
                              sysctl, CRI)             cluster doc)
                                    │
                                    ▼
                             [ Step 4 ]
                             kubelet Conditions
                             via describe node
```

**Say:**

We run the validator on the node, fix every hard FAIL, apply the documentation ConfigMap if we have API access, then read kubelet **Conditions** from `kubectl describe node` for the post-join view.

---

## Step 1 — Run the node validator on the Linux node

**What happens when you run this:**

`validate-node-setup.sh` executes local checks (no Kubernetes API required): swap, modules, sysctls, binaries, CRI socket responsiveness — as implemented in the script. It prints `[PASS]`, `[WARN]`, or `[FAIL]` per check.

**Say:**

I treat every `[FAIL]` as a blocker before `kubeadm join`. Warnings are informational.

**Run:**

On the **node under test** (copy the script there or mount the repo):

```bash
cd "$COURSE_DIR/part-1-getting-started/1.3-best-practices/1.3.3-validate-node-setup"
chmod +x scripts/*.sh 2>/dev/null || true
./scripts/validate-node-setup.sh
```

**Expected:**

Exit `0` when all required checks pass; otherwise follow Troubleshooting, fix, re-run.

---

## Step 2 — Fix common failures (reference commands)

**What happens when you run this:**

These commands change node configuration — run only for the failures the script printed.

**Say:**

Swap must be off for kubelet’s default expectations. Bridging modules and sysctls enable kube-proxy/CNI paths. If the CRI socket fails, I return to the **1.2.1.x** runtime lesson for that stack.

**Run:**

Swap off immediately and persist:

```bash
sudo swapoff -a
sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab 2>/dev/null || true
```

Load modules once and persist:

```bash
sudo modprobe overlay
sudo modprobe br_netfilter
printf '%s\n' 'overlay' 'br_netfilter' | sudo tee /etc/modules-load.d/k8s.conf >/dev/null
```

Sysctls:

```bash
sudo tee /etc/sysctl.d/k8s.conf >/dev/null <<'EOF'
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
```

**Expected:**

Script re-run reaches PASS after each addressed failure.

---

## Step 3 — Apply the in-cluster baseline (optional)

**What happens when you run this:**

`kubectl apply -f yamls/node-validation-baseline.yaml` stores a ConfigMap documenting expected node state — documentation only.

**Say:**

This gives auditors a cluster-local pointer to “what good looks like” for your platform.

**Run:**

```bash
kubectl apply -f yamls/node-validation-baseline.yaml
```

**Expected:**

ConfigMap created or unchanged.

---

## Step 4 — Read kubelet Conditions after join

**What happens when you run this:**

`kubectl describe node` prints **Conditions** such as `Ready`, `MemoryPressure`, `DiskPressure`, `PIDPressure`, and `NetworkUnavailable` — read-only API call.

**Say:**

Pre-join script catches OS prerequisites. After join, kubelet **Conditions** tell me if the node is actually healthy: `Ready` should be `True`, pressure conditions `False`, `NetworkUnavailable` `False` once CNI finishes.

**Run:**

```bash
kubectl describe node "$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')" | sed -n '/Conditions:/,/Addresses:/p'
```

**Expected:**

A `Conditions:` block showing current statuses for the first node in the list.

---

## Troubleshooting

- **`[FAIL] swap`** → run Step 2 swap commands; confirm `/proc/swaps` empty
- **`[FAIL] br_netfilter` / `overlay`** → `sudo modprobe` lines from Step 2; verify `/etc/modules-load.d/k8s.conf`
- **`[FAIL] sysctl`** → re-run `sysctl.d` block; confirm `sysctl net.ipv4.ip_forward` prints `1`
- **`[FAIL] CRI socket`** → `sudo systemctl status containerd` **or** `crio` **or** `docker` + `cri-docker`; align socket with **1.2.1.x**
- **`Ready False` after join with `NetworkUnavailable True`** → finish CNI install; not covered by the node script
- **`validate-node-setup.sh: not found` on bare node** → copy `scripts/validate-node-setup.sh` to the node or clone `$COURSE_DIR` there

---

## Learning objective

- Ran `validate-node-setup.sh` and cleared swap, module, sysctl, and CRI failures before join.
- Applied the optional baseline ConfigMap for documentation.
- Read kubelet **Conditions** from `kubectl describe node` for post-join health.

## Why this matters

Most “node joined but workloads are weird” tickets trace back to swap, bridging, forwarding, or the wrong CRI endpoint. Fixing them before join trades mystery failures for a short checklist.

## Video close — fast validation

**What happens when you run this:**

On the node: rerun the validator. From kubectl: `get nodes` plus the Conditions slice from describe.

**Say:**

Closing beat: script still green on the node, API still shows Ready with calm Conditions.

**Run:**

```bash
./scripts/validate-node-setup.sh || true
kubectl get nodes -o wide
kubectl describe node "$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')" | sed -n '/Conditions:/,/Addresses:/p'
```

**Expected:**

Validator passes on a prepared node; nodes list; Conditions block visible.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/validate-node-setup.sh` | Local prerequisite checks |
| `yamls/node-validation-baseline.yaml` | ConfigMap documenting expectations |
| `yamls/failure-troubleshooting.yaml` | Swap, sysctl, module hints |

---

## Next

[1.3.4 Enforcing Pod Security Standards](../1.3.4-enforcing-pod-security-standards/README.md)
