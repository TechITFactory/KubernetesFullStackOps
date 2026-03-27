# 1.3.5 PKI Certificates and Requirements

- Summary: Kubernetes PKI must be planned as an inventory of trust relationships, certificate lifetimes, SAN coverage, and renewal workflows.
- Content: This section includes a certificate inventory manifest and a helper script to inspect certificate expiry and SAN details on control-plane nodes.
- Lab: Inventory all cluster certificates, inspect their validity windows, and confirm the control-plane endpoint is covered by the serving cert SANs.

## Assets

- `scripts/check-k8s-pki.sh`
- `yamls/pki-inventory.yaml`
- `yamls/certificate-renewal-runbook.yaml`
