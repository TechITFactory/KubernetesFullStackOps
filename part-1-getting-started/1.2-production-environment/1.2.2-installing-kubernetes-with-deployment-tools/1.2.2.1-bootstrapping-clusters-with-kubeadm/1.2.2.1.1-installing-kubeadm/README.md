# 1.2.2.1.1 Installing kubeadm — teaching transcript

## Intro

You already have a container runtime on this node. Now you install the three binaries that turn Linux into a Kubernetes node: **`kubelet`** (node agent), **`kubectl`** (CLI client), and **`kubeadm`** (bootstrapper). All three must come from the **same Kubernetes minor** and stay **pinned** so `apt upgrade` does not jump versions overnight.

**Prerequisites:** [1.2.1 Container runtimes](../../../1.2.1-container-runtimes/README.md) on this node; Debian/Ubuntu-style `apt` (the script uses `pkgs.k8s.io`); root or `sudo`.

**Teaching tip:** **WHAT THIS DOES WHEN YOU RUN IT** is in `scripts/install-kubeadm.sh`.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.2-installing-kubernetes-with-deployment-tools/1.2.2.1-bootstrapping-clusters-with-kubeadm/1.2.2.1.1-installing-kubeadm"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]        [ Step 2 ]              [ Step 3 ]           [ Step 4 ]
  chmod scripts  →   sudo install script  →  version checks   →   kubelet status
                     (all nodes)              (PATH proof)         (expect loop)
```

**Say:**

We make the installer executable, run it as root with a chosen minor version, print versions to prove the binaries landed, then look at kubelet — it often crashes in a loop until `kubeadm init` or `join` provides config, and that is expected.

---

## Step 1 — Prepare the lesson directory

**What happens when you run this:**

`cd` moves into the lesson folder. `chmod +x scripts/*.sh` sets execute bits — metadata only.

**Say:**

I work from the repo path so `./scripts/install-kubeadm.sh` resolves the same on camera and in automation.

**Run:**

```bash
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.2-installing-kubernetes-with-deployment-tools/1.2.2.1-bootstrapping-clusters-with-kubeadm/1.2.2.1.1-installing-kubeadm"
chmod +x scripts/*.sh
pwd
```

**Expected:**

Path ending with `1.2.2.1.1-installing-kubeadm`.

---

## Step 2 — Run the install script as root on every node

**What happens when you run this:**

`install-kubeadm.sh` (as root) adds the Kubernetes `pkgs.k8s.io` apt repo for `K8S_MINOR_VERSION`, installs `kubelet`, `kubeadm`, and `kubectl`, runs `apt-mark hold` on those packages, and enables kubelet. The script is idempotent: existing keyring, repo lines, and packages are skipped safely. `systemctl enable --now kubelet` may exit non-zero before bootstrap — the script often ends with `|| true` so the overall run still succeeds.

**Say:**

I set `K8S_MINOR_VERSION` to the minor my cluster will run — for example `v1.31`. I run this on **control-plane and worker** nodes so versions match. Holds prevent accidental skew during `apt upgrade`.

**Run:**

```bash
sudo K8S_MINOR_VERSION=v1.31 ./scripts/install-kubeadm.sh
```

**Expected:**

Script completes; no duplicate-repo errors on re-run; packages installed or reported already present; holds applied.

---

## Step 3 — Verify binary versions

**What happens when you run this:**

Each command prints version metadata — no cluster required.

**Say:**

Three different jobs, three binaries — I confirm all report the same minor line my platform team expects.

**Run:**

```bash
kubeadm version
kubelet --version
kubectl version --client
```

**Expected:**

Version strings for all three; client/server wording may vary by release.

---

## Step 4 — Inspect kubelet before `kubeadm init`

**What happens when you run this:**

`systemctl status kubelet` shows whether the unit is enabled and whether it is restarting — read-only aside from systemd’s query.

**Say:**

Before init, kubelet lacks cluster config and often enters **activating (auto-restart)**. That is normal. If it is still broken **after** a successful `kubeadm init` or `join`, I troubleshoot with [1.2.2.1.2 Troubleshooting kubeadm](../1.2.2.1.2-troubleshooting-kubeadm/README.md).

**Run:**

```bash
sudo systemctl status kubelet --no-pager
```

**Expected:**

Unit enabled; state may show restart loop until kubeadm provides configuration.

---

## Reference — repository and pinning (spoken detail)

The official packages live under `https://pkgs.k8s.io/core:/stable:/<minor>/deb/`. Each minor has its own repo URL; patch releases share that repo. After install, `apt-mark hold kubelet kubeadm kubectl` blocks uncontrolled upgrades because Kubernetes upgrades are deliberate, one minor at a time, across the whole fleet.

At scale, configuration management (Ansible, cloud-init, Packer) runs the same steps this script encodes.

---

## Troubleshooting

- **`sudo: ./scripts/install-kubeadm.sh: command not found`** → run Step 1 `cd` and `chmod +x scripts/*.sh`
- **`The following signatures couldn't be verified`** → check corporate TLS inspection and keyring path; re-run after fixing apt trust
- **`404` or `Release` errors from pkgs.k8s.io** → verify `K8S_MINOR_VERSION` spelling (`v1.31` style) and outbound HTTPS
- **`kubelet` fails after successful init/join** → use diagnostics in **1.2.2.1.2**, not this lesson
- **Mixed versions across nodes** → re-run install with the same `K8S_MINOR_VERSION` on every node before joining

---

## Learning objective

- Installed `kubeadm`, `kubelet`, and `kubectl` from `pkgs.k8s.io` with version holds.
- Explained why kubelet may restart before init and why holds matter for production upgrades.
- Verified binaries on PATH and prepared for [1.2.2.1.2](../1.2.2.1.2-troubleshooting-kubeadm/README.md) or [1.2.2.1.3](../1.2.2.1.3-creating-a-cluster-with-kubeadm/README.md).

## Why this matters

Unpinned packages are how clusters accidentally land on unsupported skew. Installing once the right way saves days of upgrade firefighting later.

## Video close — fast validation

**What happens when you run this:**

Reprints the three version commands — read-only.

**Say:**

I close with the same trio I use after any image bake or ansible wave: kubeadm, kubelet, kubectl versions.

**Run:**

```bash
kubeadm version
kubelet --version
kubectl version --client
```

**Expected:**

Three version blocks with no “command not found”.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/install-kubeadm.sh` | Apt repo + install + hold + enable kubelet |
| `yamls/repo-version-plan.yaml` | Reference mapping minors to repos |
| `yamls/failure-troubleshooting.yaml` | Package, repo, and hold failures |

---

## Next

[1.2.2.1.2 Troubleshooting kubeadm](../1.2.2.1.2-troubleshooting-kubeadm/README.md)
