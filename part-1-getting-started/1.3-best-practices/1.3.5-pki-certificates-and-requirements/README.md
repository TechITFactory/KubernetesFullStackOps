# 1.3.5 PKI Certificates and Requirements

- Summary: Kubernetes PKI must be planned as an inventory of trust relationships, certificate lifetimes, SAN coverage, and renewal workflows.
- Content: This section includes a certificate inventory manifest and a helper script to inspect certificate expiry and SAN details on control-plane nodes.
- Lab: Inventory all cluster certificates, inspect their validity windows, and confirm the control-plane endpoint is covered by the serving cert SANs.

## Assets

- `scripts/check-k8s-pki.sh`
- `yamls/pki-inventory.yaml`
- `yamls/certificate-renewal-runbook.yaml`
- `yamls/failure-troubleshooting.yaml`

**Teaching tip:** `check-k8s-pki.sh` must run where `/etc/kubernetes/pki` exists (typically **control-plane** as root). Header: **WHAT THIS DOES WHEN YOU RUN IT** in the script.

## Lab Steps (Linux)

**What happens when you run this:**  
- `check-k8s-pki.sh` — `openssl` read of each `.crt`/`.pem` under PKI dir; stdout only.  
- `kubectl apply pki-inventory.yaml` — creates/updates the `pki-inventory` ConfigMap in `kube-system` (reference text, not live cert sync).  
- `kubectl apply certificate-renewal-runbook.yaml` — applies the renewal runbook ConfigMap/manifests from that file (cluster metadata only).

```bash
./scripts/check-k8s-pki.sh
kubectl apply -f yamls/pki-inventory.yaml
kubectl apply -f yamls/certificate-renewal-runbook.yaml
```

## Expected Output

- Certificate inventory lists key files and expiry windows.
- SAN and validity checks pass for active control-plane endpoint.

## Transcript

[0:00–0:30] You will validate cluster PKI before certificate failures hit production.  
[0:30–2:00] PKI issues are silent until expiry day, then they become outages.  
[2:00–7:00] Run PKI check script, review inventory, verify SAN and expiry.  
[7:00–9:00] Use troubleshooting YAML for expiry, SAN mismatch, and trust chain issues.  
[9:00–10:00] Treat certificate health checks as recurring operations work.

## Video close — fast validation

**What happens when you run this:**  
PKI dump again; first lines of `kubeadm-config` ConfigMap; nodes wide — mix of local openssl + API reads.

```bash
./scripts/check-k8s-pki.sh
kubectl get cm -n kube-system kubeadm-config -o yaml | sed -n '1,60p'
kubectl get nodes -o wide
```
