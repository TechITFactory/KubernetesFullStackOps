# 2.1.2.6 Field Selectors

- Summary: Field selectors filter objects by certain API fields when labels are not the right query mechanism.
- Content: This subsection focuses on practical field-selector usage, especially around Pod phases and Node names.
- Lab: Run the script against your cluster and compare field selectors with label selectors.

## Assets

- `scripts/field-selector-demo.sh`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/field-selector-demo.sh
```

## Expected output

- Lists Running pods cluster-wide (may be long on busy clusters) and Warning events (may be empty on a healthy cluster).

## Video close - fast validation

```bash
kubectl get pods -A --field-selector=status.phase=Running 2>/dev/null | head -n 15
kubectl get pods -A --field-selector=status.phase!=Running 2>/dev/null | head -n 15
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common unsupported field paths, server-side filter differences, and confusing empty results.
