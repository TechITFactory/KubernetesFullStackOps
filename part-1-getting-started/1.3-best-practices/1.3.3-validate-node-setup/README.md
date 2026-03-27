# 1.3.3 Validate Node Setup

- Summary: Node validation should happen before kubeadm join or workload rollout, not after failures start surfacing.
- Content: The script checks swap, sysctls, required binaries, runtime sockets, kernel modules, and kubelet prerequisites.
- Lab: Run the validator on a fresh node and fix every failed prerequisite before joining it to a cluster.

## Assets

- `scripts/validate-node-setup.sh`
- `yamls/node-validation-baseline.yaml`
