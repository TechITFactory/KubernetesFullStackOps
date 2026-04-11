# 1.2.2.1.9 Dual-stack Support with kubeadm

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.2-installing-kubernetes-with-deployment-tools/1.2.2.1-bootstrapping-clusters-with-kubeadm/1.2.2.1.9-dual-stack-support-with-kubeadm"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  confirm CNI dual-stack  →  edit dual-stack kubeadm config  →  init once  →  verify pod/service IPs
```

**Say:**

Pod and service CIDR choices are fixed at init — I decide dual-stack before the first `kubeadm init`, not after apps are running.

---

- **Summary**: Initialise a Kubernetes cluster with both IPv4 and IPv6 pod and service CIDRs — a decision that must be made before `kubeadm init` because it cannot be changed afterward.
- **Content**: IPv4 vs IPv6 vs dual-stack, what dual-stack changes in the cluster, CNI requirements, the dual-stack config structure, init script.
- **Lab**: Confirm CNI dual-stack support, review `kubeadm-dualstack-config.yaml`, run `init-dualstack-cluster.sh`, verify pods receive dual-stack addresses.

## Files

| Path | Purpose |
|------|---------|
| `scripts/init-dualstack-cluster.sh` | Idempotent: initialises a dual-stack cluster from config, skips if already initialised |
| `yamls/kubeadm-dualstack-config.yaml` | Dual-stack init config — sets IPv4 + IPv6 pod and service CIDRs, stable control-plane endpoint |

**Teaching tip:** **WHAT THIS DOES WHEN YOU RUN IT** is in `scripts/init-dualstack-cluster.sh`. Dual-stack must be chosen **before** init; CNI must support both families.

## Quick Start

**What happens when you run this:**  
- `init-dualstack-cluster.sh` — `kubeadm init --config` with dual-stack CIDRs if not already initialised.  
- `kubectl apply` Calico — installs CNI (cluster mutation); pick a version your environment can pull.  
- `kubectl get pods -A -o wide` — shows pod IPs (look for IPv4 + IPv6 columns when CNI assigns both).

```bash
# Verify your CNI supports dual-stack (Calico, Cilium, and Flannel all do)

# Initialise (run as root on control-plane node)
sudo ./scripts/init-dualstack-cluster.sh

# Install a dual-stack-capable CNI (e.g. Calico)
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

# Verify pods get dual-stack addresses
kubectl get pods -o wide -A | head -5
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

Most Kubernetes clusters run on IPv4. For most applications, that is enough.

But some environments require IPv6 — telecom networks, government infrastructure, enterprises that have exhausted their IPv4 address space, or systems that need to communicate with IPv6-only clients.

**Dual-stack** means the cluster supports both simultaneously. Pods get an IPv4 address AND an IPv6 address. Services can be reached on either.

This is a decision you make once, before `kubeadm init`. You cannot retrofit dual-stack onto an existing single-stack cluster. This lesson covers what changes, what you need, and how to do it right.

---

### [0:45–2:30] IPv4, IPv6, and Dual-stack — The Basics

**IPv4** — the address format you know: `10.244.0.1`, `192.168.1.100`. 32-bit addresses, roughly 4 billion unique addresses. We ran out of public IPv4 addresses in 2011. Private ranges (RFC 1918) are reused everywhere.

**IPv6** — the modern standard: `2001:db8::1`, `fd00::1`. 128-bit addresses. 340 undecillion unique addresses. Essentially unlimited. Adopted slowly but accelerating.

**Dual-stack** — run both protocols simultaneously. Each pod gets:
- An IPv4 address from the IPv4 pod CIDR (e.g., `10.244.0.15`)
- An IPv6 address from the IPv6 pod CIDR (e.g., `fd00::af4`)

Each Service can be:
- **IPv4** — assigned only an IPv4 cluster IP
- **IPv6** — assigned only an IPv6 cluster IP
- **IPv4+IPv6** — assigned both (PreferDualStack or RequireDualStack)

The key insight: dual-stack is additive. Existing IPv4 workloads keep working exactly as before. IPv6 capability is added on top.

---

### [2:30–3:45] What Changes in a Dual-stack Cluster

**Pod networking**: the CNI assigns two addresses per pod instead of one. Both are routable within the cluster. External routing depends on your network infrastructure.

**Service ClusterIPs**: services can have two ClusterIPs — one IPv4, one IPv6. The primary family is determined by the order of `serviceSubnet` CIDRs in the config.

**kube-proxy**: must be configured for dual-stack. In ipvs mode, this is automatic. In iptables mode, kube-proxy creates separate rule tables for IPv4 and IPv6.

**CNI requirements**: not all CNIs support dual-stack. The ones that do:
- **Calico** — full dual-stack support since v3.11
- **Cilium** — full dual-stack support, recommended for complex environments
- **Flannel** — dual-stack support since 0.20.0
- **Weave** — dual-stack support available

**Node prerequisites**: nodes must have both IPv4 and IPv6 addresses configured on their primary interface. A node that only has an IPv4 address cannot participate in dual-stack pod networking for IPv6.

---

### [3:45–5:00] The Config File

`kubeadm-dualstack-config.yaml` sets two CIDRs for each of pods and services:

```yaml
networking:
  podSubnet: "10.244.0.0/16,fd00:10:244::/56"
  serviceSubnet: "10.96.0.0/12,fd00:10:96::/108"
```

The comma-separated list specifies both an IPv4 CIDR and an IPv6 CIDR. Order matters — the first CIDR determines the **primary address family**. Here, IPv4 is primary: pods default to IPv4, services default to IPv4 unless explicitly configured for IPv6.

**IPv6 CIDR selection**: use `fd00::/8` (the ULA — Unique Local Address range) for private cluster use, just as you use RFC 1918 for IPv4. The specific `fd00::` subnets in the config are examples — use whatever fits your network plan.

**`controlPlaneEndpoint`**: must be set. For dual-stack, this can be either an IPv4 or IPv6 address — use whichever protocol is primary in your environment, or use a hostname that resolves to both.

---

### [5:00–6:15] The Init Script

`init-dualstack-cluster.sh` follows the exact same pattern as `init-control-plane.sh`:

```bash
if [[ -f /etc/kubernetes/admin.conf ]]; then
  echo "A kubeadm control plane already appears initialized. Skipping."
else
  kubeadm init --config "$CONFIG_PATH"
fi
```

Idempotent. Checks for `admin.conf` before running. Uses the dual-stack config file.

After init, verify the cluster received the correct CIDRs:

```bash
kubectl get nodes -o jsonpath='{.items[*].spec.podCIDRs}'
# Expected: [10.244.0.0/24 fd00:10:244::/64] for each node
```

Each node gets a slice of both the IPv4 and IPv6 pod subnets. The CNI uses these slices to assign pod addresses.

---

### [6:15–7:15] Verifying Dual-stack After CNI Install

After installing a dual-stack-capable CNI:

```bash
# Pods should have two IPs
kubectl get pod <pod-name> -o jsonpath='{.status.podIPs}'
# Expected: [{"ip":"10.244.0.5"},{"ip":"fd00:10:244::5"}]

# Service with dual-stack
kubectl get svc kubernetes -o jsonpath='{.spec.clusterIPs}'
# Expected: ["10.96.0.1","fd00:10:96::1"]

# Connectivity test
kubectl exec -it <pod-name> -- curl http://[fd00:10:96::1]:443/healthz -k
```

If pods only show one IP, the CNI is not configured for dual-stack. Check the CNI documentation — most require a specific annotation or configuration option to enable dual-stack mode.

---

### [7:15–8:15] Real World — Who Needs Dual-stack

**Telecom / Mobile carriers** — 5G infrastructure runs heavily on IPv6. Kubernetes control planes managing network functions need dual-stack to communicate with both legacy IPv4 equipment and new IPv6-native systems.

**Government and public sector** — many government networks mandate IPv6 compliance. Federal agencies in the US, EU, and APAC increasingly require IPv6 readiness.

**Large enterprises exhausting RFC 1918** — private IPv4 space (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) is finite. Enterprises with thousands of servers and services sometimes run out of usable private IPv4 space. IPv6 eliminates this constraint.

**ISPs and hosting providers** — offering Kubernetes as a service to customers who have IPv6-only networks.

For most product companies — a startup, a SaaS app, an internal tool — dual-stack is unnecessary complexity. The signal that you need it is specific: your infrastructure team or network team tells you it is required.

---

### [8:15–9:15] Common Pitfalls

**Node without IPv6 address** — if a worker node's network interface has no IPv6 address, the CNI cannot assign IPv6 pod addresses on that node. Check with `ip addr` on each node.

**CNI not in dual-stack mode** — installing Calico without dual-stack configuration produces single-stack networking even on a dual-stack cluster. Read the CNI's dual-stack documentation carefully.

**Service not getting dual-stack** — by default, services use the cluster's primary address family only. To get dual-stack, set `spec.ipFamilyPolicy: PreferDualStack` or `RequireDualStack` on the Service.

**Cannot add dual-stack to existing single-stack cluster** — the pod CIDR is embedded in node configuration and CNI setup. Migrating from single to dual-stack requires reprovisioning nodes. Plan this before init, not after.

---

### [9:15–10:00] Recap

- **Dual-stack** = pods and services get both IPv4 and IPv6 addresses. Additive — existing IPv4 workloads unchanged.
- **Plan before init** — pod and service CIDRs cannot be changed after `kubeadm init`. This is a one-time decision.
- **CNI must support dual-stack** — Calico, Cilium, and Flannel do. Check your CNI's documentation and enable dual-stack mode explicitly.
- **IPv6 CIDR selection** — use `fd00::/8` (ULA range) for private cluster addressing.
- Init script is **idempotent** — checks for `admin.conf`, skips if already initialised.
- **Who needs it**: telcos, government, IPv6-mandate environments. Not required for most product companies.

This completes the kubeadm bootstrapping series. Next: 1.2.3 — Turnkey Cloud Solutions, evaluating when managed Kubernetes is the better call.

## Video close — fast validation

**What happens when you run this:**  
Read-only: nodes; default `kubernetes` Service **clusterIPs** (may show two entries in dual-stack); sample pod IPs.

```bash
kubectl get nodes -o wide
kubectl get svc kubernetes -o jsonpath='{.spec.clusterIPs}{"\n"}'
kubectl get pods -A -o wide | head -n 15
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common dual-stack CIDR, CNI support, and service family-policy issues.
