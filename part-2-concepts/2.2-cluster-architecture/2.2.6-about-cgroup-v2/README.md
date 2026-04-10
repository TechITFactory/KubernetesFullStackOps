# 2.2.6 About cgroup v2

- Summary: cgroup v2 changes how Linux resource control is structured and matters for modern kubelet and runtime behavior.
- Content: Teach the cgroup driver story, unified hierarchy, and why `systemd` alignment across kubelet and runtime matters.
- Lab: Check whether a node uses cgroup v2 and compare runtime settings with kubelet expectations.

## Assets

- `scripts/check-cgroup-version.sh`
- `yamls/cgroup-v2-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/check-cgroup-version.sh
kubectl get nodes -o wide
kubectl describe node "$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')" | grep -i -E 'container runtime|kubelet version' || true
```

## Expected output

- Host cgroup mode is identified, and kubelet/runtime alignment can be verified.
- Node runtime details are visible for cross-checking cgroup driver expectations.

## Video close - fast validation

```bash
stat -fc %T /sys/fs/cgroup
kubectl get nodes -o wide
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common cgroup driver mismatch and kubelet/runtime alignment failures.
