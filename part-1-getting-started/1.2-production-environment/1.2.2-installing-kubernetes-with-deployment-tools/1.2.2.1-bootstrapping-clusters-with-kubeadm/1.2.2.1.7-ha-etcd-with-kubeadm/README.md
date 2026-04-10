# 1.2.2.1.7 Set up a High Availability etcd Cluster with kubeadm

- **Summary**: Plan and provision a dedicated external etcd cluster — endpoints, peer URLs, PKI paths — that kubeadm will use instead of managing etcd itself.
- **Content**: What etcd is, why external etcd, kubeadm's role in PKI for external members, the planning manifest structure, bootstrap script.
- **Lab**: Run `bootstrap-etcd-member.sh` on each etcd node, use kubeadm to generate etcd certificates, complete `external-etcd-cluster-plan.yaml` with real values, reference it in kubeadm init config.

## Files

| Path | Purpose |
|------|---------|
| `scripts/bootstrap-etcd-member.sh` | Idempotent: installs etcd binary, creates data and PKI directories, prints next steps |
| `yamls/external-etcd-cluster-plan.yaml` | Template for endpoint addresses, peer URLs, and PKI file locations — fill in before kubeadm init |

## Quick Start

```bash
# Run on each of the 3 dedicated etcd nodes (as root)
sudo ETCD_VERSION=v3.5.13 ./scripts/bootstrap-etcd-member.sh

# Generate etcd certificates using kubeadm (run on first etcd node)
# Then copy certs to remaining etcd nodes and control-plane nodes

# Update external-etcd-cluster-plan.yaml with actual IPs and cert paths
# Reference that plan in your kubeadm ClusterConfiguration
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

In the previous section we talked about why you might choose external etcd topology. Now we build it.

This is the most operationally complex section in the kubeadm series. External etcd means running a separate distributed database cluster — provisioned, secured, and backed up independently of Kubernetes. Before you commit to this path, you should be confident that the operational complexity is worth it for your environment.

If you chose stacked etcd — which is right for most teams — you can skip this section and move to 1.2.2.1.8.

---

### [0:45–2:30] What Is etcd?

**etcd** is a distributed key-value store — the database that holds every Kubernetes object. Every pod, every service, every ConfigMap, every Secret, every deployment — stored as key-value pairs in etcd.

Analogy: if Kubernetes is a city, etcd is the city hall archives — every decision, every record, every plan. If the archives burn down, the city doesn't stop functioning immediately (existing buildings still stand), but no new decisions can be recorded and nothing can be recovered.

**etcd characteristics:**
- Written in Go. Single binary.
- Uses the **Raft consensus algorithm** — a majority of members must agree on every write.
- Stores data on disk — performance is dominated by disk write latency. Use SSDs, never HDDs or network-attached storage.
- Supports TLS mutual authentication — every connection (client-to-server and peer-to-peer) must present a valid certificate.

In stacked etcd, kubeadm manages all of this. In external etcd, you manage it yourself.

---

### [2:30–4:00] The Certificate Chain for External etcd

This is the most complex part of external etcd: each etcd member has multiple certificates, and the control-plane nodes need additional certificates to connect as clients.

kubeadm can generate these certificates even for external etcd, but the process is manual:

```bash
# Generate the etcd CA on the first etcd node
kubeadm init phase certs etcd-ca

# Generate certificates for each etcd member
kubeadm init phase certs etcd-server
kubeadm init phase certs etcd-peer
kubeadm init phase certs etcd-healthcheck-client

# Generate apiserver-etcd-client cert (needed by the control-plane to talk to etcd)
kubeadm init phase certs apiserver-etcd-client
```

Each set of certificates must be copied to the appropriate nodes:
- etcd member certs → to each etcd node
- `apiserver-etcd-client` cert + etcd CA → to each control-plane node

This certificate distribution is the operational risk that makes external etcd harder. Automate it using Ansible or a secrets manager (Vault, AWS Secrets Manager).

---

### [4:00–5:15] The Bootstrap Script

`bootstrap-etcd-member.sh` runs on each dedicated etcd node:

**What it does:**
1. Checks if the target etcd version is already installed — skips download if yes (idempotency).
2. Downloads the etcd binary from the official GitHub release.
3. Installs `etcd` and `etcdctl` to `/usr/local/bin/`.
4. Creates the data directory (`/var/lib/etcd`) with permissions 700 — only root can read etcd data.
5. Creates the PKI directory (`/etc/kubernetes/pki/etcd`) where kubeadm will place the certificates.
6. Prints the next steps — what to do after the binary is installed.

**What it does NOT do**: start etcd, configure the systemd unit, or generate certificates. Those steps require the certificate chain to be in place first.

This separation is intentional — installing the binary is safe to do at any time. Starting etcd before certificates are ready causes immediate errors.

---

### [5:15–6:30] The Planning Manifest

`external-etcd-cluster-plan.yaml` is not a Kubernetes YAML — it is a structured planning document (using YAML as a readable format) that you fill in before kubeadm init.

It records:
- Etcd member names, IP addresses, and peer URLs
- Client endpoint URLs (what the API server connects to)
- Certificate and key file paths for each member
- Data directory locations

Completing this document before touching kubeadm forces you to answer every question upfront:
- What are the etcd node IPs?
- Where will certificates live?
- What is the peer communication URL for each member?

These values then go into your kubeadm `ClusterConfiguration`:

```yaml
etcd:
  external:
    endpoints:
      - "https://10.0.0.11:2379"
      - "https://10.0.0.12:2379"
      - "https://10.0.0.13:2379"
    caFile: "/etc/kubernetes/pki/etcd/ca.crt"
    certFile: "/etc/kubernetes/pki/apiserver-etcd-client.crt"
    keyFile: "/etc/kubernetes/pki/apiserver-etcd-client.key"
```

---

### [6:30–7:30] etcd Port Reference

etcd uses two ports:

| Port | Purpose |
|------|---------|
| 2379 | **Client port** — API server connects here to read/write cluster state |
| 2380 | **Peer port** — etcd members connect to each other here for Raft replication |

Both ports must be open between all etcd nodes (for peering) and from all control-plane nodes to etcd nodes (for client traffic). Firewall rules are a common source of external etcd failures.

---

### [7:30–8:30] Operating etcd After Bootstrap

External etcd comes with ongoing operational responsibilities that stacked etcd handles automatically:

**Backups** — etcd data must be backed up regularly:
```bash
etcdctl snapshot save /backup/etcd-snapshot-$(date +%Y%m%d).db \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key
```

**Monitoring** — watch etcd metrics at `:2379/metrics`. Key metrics: `etcd_server_has_leader` (must be 1), `etcd_disk_wal_fsync_duration_seconds` (must be low — high values indicate disk pressure).

**Certificate rotation** — etcd certificates expire (usually 1 year). Set a calendar reminder. Expired etcd certificates crash the entire cluster.

**Defragmentation** — over time, etcd accumulates fragmented space. Run periodically:
```bash
etcdctl defrag --endpoints=https://127.0.0.1:2379 --cacert=... --cert=... --key=...
```

---

### [8:30–9:30] Real World — Who Actually Uses External etcd

External etcd is common in:

- **Large clusters** (500+ nodes) — where etcd write throughput becomes a bottleneck and dedicated hardware is justified.
- **Regulated industries** — where auditors require strict separation between the cluster control plane and the database that stores secrets.
- **Managed service providers** — who run etcd as a separately SLA'd service across multiple customer clusters.
- **Kubernetes distributions** — OpenShift, Rancher, and k0s all manage etcd separately from the control plane in their HA configurations.

For a team running a 20-node cluster for a single product, the overhead is rarely worth it. For a platform team running 10+ clusters serving dozens of product teams, external etcd with dedicated monitoring and backup pipelines is common practice.

---

### [9:30–10:00] Recap

- **etcd** = the cluster database. Every Kubernetes object lives here. Losing it without a backup means losing the cluster.
- **External etcd** = 3+ dedicated etcd nodes, provisioned and operated separately from Kubernetes.
- **bootstrap-etcd-member.sh** — installs the binary, creates directories, idempotent. Does not start etcd.
- **Certificate complexity** — the hardest part of external etcd. Use kubeadm's `phase certs` commands and automate distribution.
- **Ongoing ops**: backups, certificate rotation, defragmentation, monitoring. Budget time for these.

Next: 1.2.2.1.8 — Configuring each kubelet in your cluster using kubeadm.

## Video close — fast validation

```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system | grep -E 'etcd|kube-apiserver' || kubectl get pods -n kube-system | head
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common etcd quorum, cert, endpoint-health, and backup/restore failures.
