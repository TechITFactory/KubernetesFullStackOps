# 1.3.4 Enforcing Pod Security Standards

- Summary: Pod Security Standards should be enforced intentionally with namespace labels and validated with safe and unsafe example workloads.
- Content: This section provides namespace labeling automation and sample manifests for `restricted` enforcement testing.
- Lab: Label a namespace for `restricted`, apply the compliant manifest successfully, then observe the non-compliant manifest fail admission.

## Assets

- `scripts/apply-pod-security-labels.sh`
- `yamls/restricted-namespace.yaml`
- `yamls/restricted-compliant-pod.yaml`
- `yamls/restricted-noncompliant-pod.yaml`
- `yamls/failure-troubleshooting.yaml`

## Lab Steps (Linux)

```bash
./scripts/apply-pod-security-labels.sh
kubectl apply -f yamls/restricted-namespace.yaml
kubectl apply -f yamls/restricted-compliant-pod.yaml
kubectl apply -f yamls/restricted-noncompliant-pod.yaml
```

## Expected Output

- Compliant pod is admitted and runs.
- Non-compliant pod is denied by admission policy.

## Transcript

[0:00–0:30] You will enforce pod security in a way teams use in production clusters.  
[0:30–2:00] Namespace-level enforcement is the safest and clearest rollout model.  
[2:00–7:00] Apply labels and manifests, then confirm allow/deny behavior.  
[7:00–9:00] Use troubleshooting YAML for policy mismatch and admission failures.  
[9:00–10:00] Security is real only when non-compliant workloads are blocked.

## Video close — fast validation

```bash
kubectl get ns --show-labels | grep restricted
kubectl get pods -A
kubectl apply -f yamls/restricted-noncompliant-pod.yaml
```
