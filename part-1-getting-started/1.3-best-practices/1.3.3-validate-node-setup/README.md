# 1.3.3 Validate Node Setup

- Summary: Node validation should happen before kubeadm join or workload rollout, not after failures start surfacing.
- Content: The script checks swap, sysctls, required binaries, runtime sockets, kernel modules, and kubelet prerequisites.
- Lab: Run the validator on a fresh node and fix every failed prerequisite before joining it to a cluster.

## Assets

- `scripts/validate-node-setup.sh`
- `yamls/node-validation-baseline.yaml`
- `yamls/failure-troubleshooting.yaml`

## Lab Steps (Linux)

```bash
./scripts/validate-node-setup.sh
kubectl apply -f yamls/node-validation-baseline.yaml
```

## Expected Output

- Validator returns all required node prerequisites as pass.
- Baseline checks confirm runtime/kubelet readiness.

## Transcript

[0:00–0:30] You will prevent bad nodes from ever joining your cluster.  
[0:30–2:00] Most cluster instability starts with unvalidated node prerequisites.  
[2:00–7:00] Run validator, review every failed item, re-run until clean.  
[7:00–9:00] Use troubleshooting YAML to fix swap, sysctl, runtime, and kubelet issues.  
[9:00–10:00] Node validation is a hard gate before any join operation.

## Video close — fast validation

```bash
./scripts/validate-node-setup.sh
kubectl get nodes -o wide
kubectl describe node "$(kubectl get nodes -o name | sed -n '1p' | cut -d'/' -f2)" | sed -n '1,40p'
```
