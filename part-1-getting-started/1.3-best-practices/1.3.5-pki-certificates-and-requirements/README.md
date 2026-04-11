# 1.3.5 PKI Certificates and Requirements — teaching transcript

- **Summary**: Kubernetes PKI must be planned as an inventory of trust relationships, certificate lifetimes, SAN coverage, and renewal workflows — before expiry forces your hand.
- **Content**: PKI component overview, certificate expiry inspection, SAN verification, and the renewal runbook.
- **Lab**: Inventory all cluster certificates, inspect their validity windows, and confirm the control-plane endpoint is covered by the serving cert SANs.

## Assets

- `scripts/check-k8s-pki.sh`
- `yamls/pki-inventory.yaml`
- `yamls/certificate-renewal-runbook.yaml`
- `yamls/failure-troubleshooting.yaml`

**Teaching tip:** `check-k8s-pki.sh` must run **on the control-plane node** where `/etc/kubernetes/pki` exists, typically as root. **WHAT THIS DOES WHEN YOU RUN IT** is in the script header.

---

## Intro

Here's the thing about certificate expiry.

It's silent until the day it isn't. The cluster runs fine, then one morning the API server stops accepting connections. `kubectl` returns `x509: certificate has expired or is not yet valid`. Every component that talks to the API server — kubelet, controller-manager, scheduler, your CI/CD pipelines — fails simultaneously. Your cluster is down and the fix requires root access to every control-plane node.

This is 100% preventable. Kubernetes certificates have known expiry dates. `kubeadm` creates them with a 1-year lifetime by default. The renewal command exists and works. The only failure mode is not knowing when to run it.

This lesson teaches you to read the PKI inventory, check expiry windows, verify SAN coverage, and run renewal before it becomes an emergency.

---

## Flow of this lesson

**Say:**
Three steps. Run the PKI check script to see current expiry windows. Apply the inventory ConfigMap to record what's in the PKI. Then apply the renewal runbook so you have it in the cluster as reference.

```
  [ Step 1 ]              [ Step 2 ]              [ Step 3 ]
  Run PKI check   →       Apply PKI        →      Apply renewal
  script — see            inventory               runbook ConfigMap
  expiry dates            ConfigMap
```

---

## Step 1 — Run the PKI check script

**What happens when you run this:**
`check-k8s-pki.sh` runs on the control-plane node where `/etc/kubernetes/pki` is located. It uses `openssl x509 -noout -dates` and `-text` to read each `.crt` and `.pem` file in the PKI directory, extracting:
- **Subject** — what the cert identifies
- **Not After** — when it expires
- **SANs** — the Subject Alternative Names (for serving certs)

Output is human-readable. The script does not modify any files — read-only.

**Say:**
I run this as root on the control-plane node because the PKI files are root-owned. It reads the actual certificate files on disk — not the live API server, not a ConfigMap. This means it works even if the API server is down, which is exactly when you need it most.

**Run:**

```bash
sudo ./scripts/check-k8s-pki.sh
```

**Expected:**
For each certificate: subject, expiry date, and SAN list. You're looking for expiry dates more than 30 days out. Anything under 30 days should be renewed immediately.

---

## What the PKI contains

Kubernetes uses a layered PKI with two Certificate Authorities:

**Cluster CA** (`/etc/kubernetes/pki/ca.crt`):
Signs all cluster-internal certificates. The API server serving cert, the controller-manager client cert, the scheduler client cert, and all kubelet client certs are signed by this CA.

**etcd CA** (`/etc/kubernetes/pki/etcd/ca.crt`):
Signs all etcd-related certificates. The etcd server cert, peer certs, and the API server's etcd client cert are signed by this CA.

**Front-proxy CA** (`/etc/kubernetes/pki/front-proxy-ca.crt`):
Signs the front-proxy client cert used by the API server when acting as a proxy for API aggregation.

**Key certificates and typical expiry:**

| Certificate | Path | Expires |
|-------------|------|---------|
| API server serving cert | `pki/apiserver.crt` | 1 year |
| API server etcd client | `pki/apiserver-etcd-client.crt` | 1 year |
| Controller manager | `pki/controller-manager.conf` | 1 year |
| Scheduler | `pki/scheduler.conf` | 1 year |
| Kubelet client (per node) | `/var/lib/kubelet/pki/kubelet-client-current.pem` | 1 year (auto-rotated if enabled) |
| Cluster CA | `pki/ca.crt` | 10 years |
| etcd CA | `pki/etcd/ca.crt` | 10 years |

The 1-year certificates are the ones that need annual renewal. CAs typically last 10 years but should also be planned for rotation.

---

## SAN coverage — why it matters

The API server serving certificate (`apiserver.crt`) includes a list of Subject Alternative Names — the hostnames and IP addresses that clients are allowed to connect through. If a client connects using a name or IP that is not in the SAN list, the TLS handshake fails with an x509 error.

**Common SANs for the API server:**
- `kubernetes`
- `kubernetes.default`
- `kubernetes.default.svc`
- `kubernetes.default.svc.cluster.local`
- The control-plane node IP
- The Kubernetes Service cluster IP (usually `10.96.0.1`)
- Your load balancer DNS name (for HA clusters)

**Say:**
The last one is the one teams miss. If you have a load balancer in front of your API server and its DNS name is not in the SAN list, every connection through the load balancer fails. `check-k8s-pki.sh` prints the SANs so you can verify this before renewal.

---

## Step 2 — Apply the PKI inventory

**What happens when you run this:**
`kubectl apply -f yamls/pki-inventory.yaml` creates or updates a ConfigMap in `kube-system` that documents your cluster's PKI layout — certificate paths, expected SANs, renewal schedule. This is reference documentation stored in the cluster, not live certificate data.

**Say:**
I store the inventory in the cluster so any engineer with cluster access can read it — not just the one who set it up. During an incident at 2am, "where is the etcd CA cert?" should have an answer in the cluster itself.

**Run:**

```bash
kubectl apply -f yamls/pki-inventory.yaml
```

**Expected:**
ConfigMap created or unchanged in `kube-system`.

---

## Step 3 — Apply the renewal runbook

**What happens when you run this:**
`kubectl apply -f yamls/certificate-renewal-runbook.yaml` stores the renewal procedure as a ConfigMap in `kube-system`. It documents the `kubeadm certs renew` commands, the order of operations, and the verification steps.

**Say:**
The renewal runbook being in the cluster means you can read it even when you're SSH-ed into a control-plane node without access to external documentation. Runbooks in the cluster are a practice I recommend for any operational procedure that requires root access under pressure.

**Run:**

```bash
kubectl apply -f yamls/certificate-renewal-runbook.yaml
```

**Expected:**
ConfigMap created or unchanged.

---

## How to renew certificates with kubeadm

When expiry is approaching (or has happened), the renewal commands are:

```bash
# Check current expiry for all certs at once
sudo kubeadm certs check-expiration

# Renew all certificates
sudo kubeadm certs renew all

# Restart control-plane static pods to pick up new certs
# (kubeadm renew does not restart them automatically)
sudo crictl rm $(sudo crictl ps -q)
# OR move manifests away and back to trigger kubelet restart:
sudo mv /etc/kubernetes/manifests/*.yaml /tmp/
sleep 5
sudo mv /tmp/*.yaml /etc/kubernetes/manifests/
```

After renewal, copy the updated kubeconfig files to users who need them:
```bash
# Admin kubeconfig is updated in place by kubeadm certs renew
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
```

**Set a calendar reminder** 60 days before expiry. `kubeadm certs check-expiration` gives you the dates. Put them in your team's on-call calendar — not just your own.

---

## Kubelet certificate auto-rotation

Kubelet client certificates can rotate automatically if enabled. To check:

```bash
kubectl get cm -n kube-system kubelet-config -o yaml | grep rotateCertificates
```

If `rotateCertificates: true`, kubelet renews its own client cert before expiry without intervention. This is the recommended configuration and is enabled by default in recent kubeadm clusters.

Kubelet *serving* certificates (used when the API server calls back to the kubelet) require manual approval or a controller — check with `kubectl get csr` for pending signing requests.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/check-k8s-pki.sh` | Reads `/etc/kubernetes/pki` — expiry dates and SANs |
| `yamls/pki-inventory.yaml` | ConfigMap documenting PKI layout and renewal schedule |
| `yamls/certificate-renewal-runbook.yaml` | ConfigMap with kubeadm renewal procedure |
| `yamls/failure-troubleshooting.yaml` | Expiry, SAN mismatch, and trust chain failure fixes |

---

## Troubleshooting

- **`x509: certificate has expired`** → run `sudo kubeadm certs renew all` immediately; restart static pods; update kubeconfig
- **SAN mismatch on load balancer** → the LB DNS/IP was not in the original `apiserver.crt` SAN list; renew with a kubeadm config that includes the correct `certSANs`
- **`kubectl` fails but `crictl` works** → API server is up but kubeconfig has expired cert; regenerate or copy from `/etc/kubernetes/admin.conf`
- **Kubelet NotReady after cert renewal** → kubelet may need restart: `sudo systemctl restart kubelet`
- **etcd cert expiry** → same `kubeadm certs renew all` covers etcd certs; verify with `etcdctl member list` after restart

---

## Learning objective

- Run the PKI check script and read certificate expiry dates and SANs.
- Identify the six most important Kubernetes certificates and their typical lifetime.
- Run `kubeadm certs renew all` and describe the steps needed after renewal.
- Set up a recurring reminder for certificate renewal before expiry.

## Why this matters

Certificate expiry is a predictable failure. Unlike a node crash or a bug, you always know it is coming. Teams that track certificate expiry as a recurring operational task never experience cert-caused outages. Teams that don't track it eventually do.

---

## Video close — fast validation

**What happens when you run this:**
PKI check again; first lines of the `kubeadm-config` ConfigMap in `kube-system`; nodes wide — a mix of local cert reads and cluster API.

**Say:**
I end every cluster health check with `kubeadm certs check-expiration` — that's the authoritative view. The script I wrote earlier reads the raw files; this command reads the same certs and formats them as a table with days-remaining. Either one works; the important thing is running one of them regularly.

```bash
sudo kubeadm certs check-expiration
kubectl get cm -n kube-system kubeadm-config -o yaml | head -n 30
kubectl get nodes -o wide
```

---

## Next

You have completed **1.3 Best Practices**. Continue to [Part 2: Concepts](../../../part-2-concepts/README.md).

Run the prerequisite check first:
```bash
bash part-2-concepts/scripts/verify-part2-prerequisites.sh
```
(from the repo root)
