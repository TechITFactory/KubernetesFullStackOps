# 05 PKI Certificates and Requirements â€” teaching transcript

## Intro

Certificate expiry is silent until the morning `kubectl` prints `x509: certificate has expired or is not yet valid` and every automation path breaks at once.

Kubernetes control-plane certificates have known **NotAfter** dates. `kubeadm` defaults to about one year for many leaf certs. You can **renew** them with `kubeadm certs renew`, but static control-plane pods **do not always reload** files on disk until they restart â€” so renewal and restart are one story.

This lesson inventories PKI with `check-k8s-pki.sh`, stores reference ConfigMaps, walks **`kubeadm certs check-expiration`** and **`kubeadm certs renew all`**, reminds you to **bounce static pods** (or restart containers) after renewal, checks kubelet client rotation, and sets a **calendar reminder roughly sixty days before** the next `NotAfter`.

**Teaching tip:** `check-k8s-pki.sh` must run **on a control-plane node** where `/etc/kubernetes/pki` exists, typically as root.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/03-best-practices/05-pki-certificates"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]              [ Step 2 ]              [ Step 3 ]
  sudo PKI script   â†’     kubectl apply      â†’     kubectl apply
  on control plane        inventory CM           renewal runbook CM
        â”‚
        â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                                                       â–¼
                                            renewal + static pod
                                            restart story (Say)
```

**Say:**

On the node I read real PEM files with the helper script. From kubectl I drop reference ConfigMaps. Then I narrate `kubeadm` renewal, restarting static manifests, refreshing kubeconfig, kubelet rotation, and the calendar habit.

---

## Step 1 â€” Run the PKI check script (control-plane node)

**What happens when you run this:**

`check-k8s-pki.sh` reads certificates under `/etc/kubernetes/pki` with `openssl` â€” subjects, dates, **SANs** â€” read-only.

**Say:**

I run this as root on the control plane because the files are root-owned. It still works when the API is unhealthy â€” that is when I need it most.

**Run:**

On the control-plane node:

```bash
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/03-best-practices/05-pki-certificates"
chmod +x scripts/*.sh 2>/dev/null || true
sudo ./scripts/check-k8s-pki.sh
```

**Expected:**

Human-readable lines per certificate; verify **Not After** and SAN list includes load-balancer DNS if clients use one.

---

## Certificate inventory (reference table)

| Certificate / material | Typical path | Notes |
|------------------------|--------------|-------|
| Cluster CA | `/etc/kubernetes/pki/ca.crt` | Long-lived; plan rotation separately |
| API server serving cert | `/etc/kubernetes/pki/apiserver.crt` | Must list SANs for LB DNS/IP clients use |
| API server etcd client | `/etc/kubernetes/pki/apiserver-etcd-client.crt` | Signed by etcd CA |
| etcd peers / server | `/etc/kubernetes/pki/etcd/*.crt` | HA etcd stacks add peer aliases |
| Front-proxy | `/etc/kubernetes/pki/front-proxy-*.crt` | Aggregation layer trust |
| Admin kubeconfig | `/etc/kubernetes/admin.conf` | Client cert inside |
| Kubelet client (live) | `/var/lib/kubelet/pki/kubelet-client-current.pem` | May auto-rotate |

---

## Step 2 â€” Apply the PKI inventory ConfigMap

**What happens when you run this:**

`kubectl apply -f yamls/pki-inventory.yaml` stores documentation in `kube-system` â€” not live cert data.

**Say:**

Engineers with RBAC to read `kube-system` ConfigMaps can learn where PEM files live without SSH if you keep this updated.

**Run:**

```bash
kubectl apply -f yamls/pki-inventory.yaml
```

**Expected:**

ConfigMap created or unchanged.

---

## Step 3 â€” Apply the renewal runbook ConfigMap

**What happens when you run this:**

`kubectl apply -f yamls/certificate-renewal-runbook.yaml` stores operational text for renewals.

**Say:**

During an outage, having the runbook object inside the cluster beats hunting wikis from a jump host.

**Run:**

```bash
kubectl apply -f yamls/certificate-renewal-runbook.yaml
```

**Expected:**

ConfigMap created or unchanged.

---

## Step 4 â€” Renewal commands and static pod restart (narrated + optional run)

**What happens when you run this:**

`kubeadm certs check-expiration` prints authoritative dates. `sudo kubeadm certs renew all` writes fresh PEM material. **Static pod manifests** under `/etc/kubernetes/manifests` must be restarted so apiserver, scheduler, and controller-manager pick up new files â€” common pattern: move manifests aside briefly or restart containers via `crictl` per your runbook.

**Say:**

Renewal updates files on disk; kubelet reconciles static pods from manifests. After renewal I copy refreshed admin kubeconfig to operators who need it, and I set a **calendar reminder about sixty days before** the next `NotAfter` from `check-expiration`. I also confirm kubelet client rotation with `rotateCertificates` in kubelet config.

**Run:**

```bash
sudo kubeadm certs check-expiration
# When maintenance window allows:
# sudo kubeadm certs renew all
# Then restart static pods per your organization's runbook, for example:
# sudo mv /etc/kubernetes/manifests/*.yaml /tmp/k8s-manifests-backup/
# sleep 20
# sudo mv /tmp/k8s-manifests-backup/*.yaml /etc/kubernetes/manifests/
```

**Expected:**

`check-expiration` prints a table. Commented renewal lines are intentionally not executed in the transcript â€” run only on real maintenance.

Kubelet rotation hint:

```bash
kubectl get cm -n kube-system kubelet-config -o yaml 2>/dev/null | grep -i rotateCertificates || true
```

---

## Troubleshooting

- **`check-k8s-pki.sh: PKI directory missing`** â†’ run on a control-plane node where kubeadm initialized the cluster
- **`x509: certificate has expired or is not yet valid` from `kubectl`** â†’ renew with `kubeadm certs renew all`, restart static pods, redistribute kubeconfig
- **Load balancer TLS errors despite renewed files** â†’ SAN list on `apiserver.crt` never included the LB hostname; renew with a kubeadm config that lists `certSANs`
- **`kubectl` works but kubelets cannot talk to API** â†’ kubelet client cert not rotated; check kubelet logs and CSR objects
- **`kubelet-config` ConfigMap missing** â†’ some installers store kubelet settings elsewhere; fall back to node `/var/lib/kubelet/config.yaml` for `rotateCertificates`

---

## Learning objective

- Ran `check-k8s-pki.sh` and read **Not After** dates plus **SAN** coverage for the API server cert.
- Applied inventory and runbook ConfigMaps for operator documentation.
- Described `kubeadm certs renew all`, static pod restart expectations, kubelet auto-rotation checks, and scheduling renewal work **sixty days before** expiry.

## Why this matters

Expiry is predictable. Teams that calendar it never learn about PKI from a total API outage; teams that ignore it always do.

## Video close â€” fast validation

**What happens when you run this:**

Read-only: `kubeadm certs check-expiration` on the control plane, first lines of `kubeadm-config` ConfigMap, nodes wide.

**Say:**

I show the authoritative expiration table, peek at kubeadm config for SAN planning, then confirm nodes still report Ready.

**Run:**

```bash
sudo kubeadm certs check-expiration
kubectl get cm -n kube-system kubeadm-config -o yaml 2>/dev/null | head -n 30 || true
kubectl get nodes -o wide
```

**Expected:**

Expiration table; ConfigMap header or empty if RBAC denies; nodes listed.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/check-k8s-pki.sh` | Local PEM inspection |
| `yamls/pki-inventory.yaml` | PKI documentation ConfigMap |
| `yamls/certificate-renewal-runbook.yaml` | Renewal procedure ConfigMap |
| `yamls/failure-troubleshooting.yaml` | PKI failure hints |

---

## Next

You have completed **03 Best Practices**. Continue to [Part 2: Concepts](../../../part-2-concepts/README.md).

Run the prerequisite check from the repo root:

```bash
bash part-2-concepts/scripts/verify-part2-prerequisites.sh
```
