# 1.2.2.1.4 Customizing Components with the kubeadm API

- **Summary**: Override default API server flags, controller-manager settings, kube-proxy mode, and etcd configuration through a structured kubeadm config file instead of command-line arguments.
- **Content**: Why config files beat flags, the kubeadm config API structure, key customisation points, validating config before init.
- **Lab**: Review `custom-cluster-config.yaml`, run `validate-kubeadm-config.sh` to confirm it is valid, use it as the `--config` argument for `kubeadm init`.

## Files

| Path | Purpose |
|------|---------|
| `scripts/validate-kubeadm-config.sh` | Runs `kubeadm config validate` and prints the effective defaults for comparison |
| `yamls/custom-cluster-config.yaml` | Reference config — customises API server SANs, kube-proxy mode, controller-manager flags |

## Quick Start

```bash
# Validate before using
./scripts/validate-kubeadm-config.sh

# Use in cluster init
sudo kubeadm init --config yamls/custom-cluster-config.yaml
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

In the previous section we ran `kubeadm init --config kubeadm-init-config.yaml`. That config covered the essentials — pod CIDR, control-plane endpoint, CRI socket. But kubeadm's configuration API goes much deeper.

This lesson is about taking control of every Kubernetes component through that config file — and why doing so through files rather than flags is a production requirement, not a preference.

---

### [0:45–2:00] Config Files vs Flags — Why It Matters

Flags are convenient for trying things. Configs are required for operating things.

Consider two ways to set the same API server flag:

**Flags approach:**
```bash
kubeadm init \
  --apiserver-cert-extra-sans=api.mycompany.com \
  --pod-network-cidr=10.244.0.0/16 \
  --service-cidr=10.96.0.0/12 \
  --control-plane-endpoint=api.mycompany.com:6443
```

**Config approach:**
```yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
controlPlaneEndpoint: "api.mycompany.com:6443"
apiServer:
  certSANs:
    - "api.mycompany.com"
```

The config is:
- **Stored in git** — your cluster's configuration is a reviewed, versioned artefact.
- **Self-documenting** — new team members can read what was configured and why.
- **Reproducible** — the same file produces the same cluster. The flag list in a terminal history is not reproducible.
- **Auditable** — security teams can review what API server flags are set without SSHing into the control plane.

**Real rule**: flags are for local experiments. Config files are for anything that runs longer than a day.

---

### [2:00–4:00] The kubeadm Config API Structure

A kubeadm config file can contain multiple documents separated by `---`. Each document has a `kind` that targets a specific component:

| Kind | Targets | Key settings |
|------|---------|-------------|
| `InitConfiguration` | kubeadm init behaviour | Node registration, CRI socket, bootstrap token |
| `ClusterConfiguration` | Control-plane components | API server, controller-manager, scheduler, etcd, networking |
| `KubeletConfiguration` | kubelet on all nodes | Cgroup driver, eviction, authentication |
| `KubeProxyConfiguration` | kube-proxy | Mode (iptables, ipvs, nftables) |

These four kinds give you control over every component kubeadm manages. You can put all of them in one file.

---

### [4:00–5:45] Key Customisation Points

**API Server SANs** — the TLS certificate kubeadm generates for the API server only covers the node's hostname and IP by default. If you want to reach it via a load balancer hostname or a custom DNS name, add it here:

```yaml
apiServer:
  certSANs:
    - "api.mycompany.com"
    - "10.0.0.100"
```

Missing this means `kubectl` from a remote machine gets a TLS error — the hostname doesn't match the certificate.

**kube-proxy mode** — the default is `iptables`. If your cluster has many services (thousands), consider `ipvs` which scales better:

```yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
```

**Controller-manager flags** — for example, setting a node eviction rate during failure:

```yaml
controllerManager:
  extraArgs:
    node-monitor-grace-period: "20s"
    pod-eviction-timeout: "30s"
```

**Feature gates** — enable or disable specific Kubernetes features by name:

```yaml
apiServer:
  extraArgs:
    feature-gates: "SidecarContainers=true"
```

---

### [5:45–7:00] Validating Before You Init

`validate-kubeadm-config.sh` runs:

```bash
kubeadm config validate --config custom-cluster-config.yaml
```

This parses the config against the kubeadm API schema and reports errors — unknown fields, invalid values, conflicting settings — before you attempt `kubeadm init`. A validation failure here takes seconds to fix. The same issue discovered mid-init requires cleanup and a retry.

The script also runs:
```bash
kubeadm config print init-defaults
```
This shows you the full default config. You can see exactly what you are overriding and what is being left at the default. Useful for understanding the impact of your changes.

**Always validate before init** — especially when changing the config for a cluster upgrade or reprovisioning.

---

### [7:00–8:30] Real World — Config in GitOps Workflows

At companies running GitOps, the kubeadm config file lives in a repository:

```
infrastructure/
  clusters/
    production/
      kubeadm-init-config.yaml   ← reviewed and approved by platform team
      kube-proxy-config.yaml
    staging/
      kubeadm-init-config.yaml
```

Before a cluster is provisioned, a pull request is opened with the config. Another engineer reviews it. The config is merged. Only then does Terraform or Ansible run `kubeadm init --config` pointing at the approved file.

This means:
- Every cluster configuration decision is recorded in git history.
- Changes require review — no one person can silently change API server flags in production.
- Rollback is `git revert` + reprovisioning.

This is considered best practice for any cluster that handles customer data or has compliance requirements.

---

### [8:30–9:30] Updating Config After Init

kubeadm stores the config it used in a ConfigMap in the cluster:

```bash
kubectl get cm kubeadm-config -n kube-system -o yaml
```

This is used by `kubeadm upgrade` to understand what the cluster was initialised with. If you need to change a flag post-init, the process is:

1. Drain the control-plane node.
2. Edit the kubeadm ConfigMap or pass a new config file to `kubeadm upgrade apply`.
3. Let kubeadm regenerate the static pod manifests.

Never manually edit `/etc/kubernetes/manifests/` static pod files — kubeadm will overwrite them on the next upgrade.

---

### [9:30–10:00] Recap

- **Config files over flags** — versioned, reviewable, reproducible, auditable.
- **Four kinds**: `InitConfiguration`, `ClusterConfiguration`, `KubeletConfiguration`, `KubeProxyConfiguration`.
- **Critical customisations**: API server SANs (required for custom endpoints), kube-proxy mode, controller-manager tuning, feature gates.
- **Always validate** with `kubeadm config validate` before running `kubeadm init`.
- The config used at init is stored in `kube-system/kubeadm-config` ConfigMap for upgrade reference.

Next: 1.2.2.1.5 — Options for Highly Available Topology, where we choose how to design a cluster that survives control-plane node failure.
