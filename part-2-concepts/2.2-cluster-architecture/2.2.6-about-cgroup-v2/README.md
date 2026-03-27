# 2.2.6 About cgroup v2

- Summary: cgroup v2 changes how Linux resource control is structured and matters for modern kubelet and runtime behavior.
- Content: Teach the cgroup driver story, unified hierarchy, and why `systemd` alignment across kubelet and runtime matters.
- Lab: Check whether a node uses cgroup v2 and compare runtime settings with kubelet expectations.

## Assets

- `scripts/check-cgroup-version.sh`
- `yamls/cgroup-v2-notes.yaml`
