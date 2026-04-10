# 3.2.19 Control Memory Management Policies on a Node

- Duration: 20 minutes
- Difficulty: Intermediate
- Practical/Theory: 70/30
- Tested on Kubernetes: latest stable
- Also valid for: previous stable

## Learning Objective

By the end of this lesson, you will be able to:

- Explain what kubelet memory management policies do.
- Configure a kubelet memory manager policy on a node.
- Verify the node and workload behavior after policy change.

## Why This Matters in Real Jobs

Latency-sensitive and memory-critical workloads (for example, data engines and real-time processors) can behave unpredictably if memory allocation is not controlled carefully. Platform engineers are expected to tune node behavior to improve workload stability.

## Prerequisites

- A local Kubernetes cluster where you can change kubelet config (kubeadm-based node preferred).
- `kubectl` configured with cluster-admin permissions.
- SSH or local shell access to at least one worker node.

## Concepts (Short Theory)

- Kubelet memory manager coordinates memory allocation behavior for pods.
- Policy choices affect predictability and performance characteristics.
- Node-level policy tuning should be validated with controlled test pods.

## Lab: Step-by-Step Practical

### Step 1 - Confirm node and kubelet status

```bash
kubectl get nodes -o wide
kubectl describe node <node-name> | grep -i -E "kubelet|allocatable|capacity"
```

### Step 2 - Inspect current kubelet configuration on the node

On the target node:

```bash
sudo cat /var/lib/kubelet/config.yaml | grep -i -E "memoryManagerPolicy|reservedMemory|cpuManagerPolicy"
```

If `memoryManagerPolicy` is not set, kubelet uses default behavior.

### Step 3 - Update kubelet config for a memory policy

Edit kubelet config on the node:

```bash
sudo vi /var/lib/kubelet/config.yaml
```

Add or update:

```yaml
memoryManagerPolicy: "Static"
```

Save and restart kubelet:

```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl status kubelet --no-pager
```

### Step 4 - Validate node is healthy again

```bash
kubectl get nodes
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```

### Step 5 - Deploy a validation workload

Create a test pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-policy-check
spec:
  containers:
    - name: app
      image: registry.k8s.io/pause:3.10
      resources:
        requests:
          memory: "128Mi"
        limits:
          memory: "128Mi"
```

Apply and verify:

```bash
kubectl apply -f memory-policy-check.yaml
kubectl get pod memory-policy-check -o wide
kubectl describe pod memory-policy-check
```

## Expected Output

- Node returns to `Ready` state after kubelet restart.
- Test pod reaches `Running` without unexpected scheduling failures.
- Kubelet logs do not show repeated config parse failures.

## Troubleshooting (Top 5)

1. Node stuck `NotReady` after kubelet restart -> check YAML indentation and kubelet config syntax.
2. Kubelet fails to start -> review `sudo journalctl -u kubelet -xe`.
3. Pod remains `Pending` -> verify node allocatable memory and taints.
4. Wrong node tested -> use `kubectl get pod -o wide` to confirm node placement.
5. Changes lost after node rebuild -> manage config via automation/infra scripts.

## Hands-On Challenge

- Apply the same policy to a second node.
- Compare pod placement and behavior before and after the policy change.

## Assessment

- Quiz:
  - Why should memory policy changes be validated with test pods?
  - What is the first log source to check if kubelet fails after config edits?
- Practical check:

```bash
kubectl get node <node-name> -o yaml | grep -i -E "allocatable|capacity"
kubectl get pod memory-policy-check -o wide
```

## Version and Compatibility Notes

- Some memory manager behaviors are feature-gate sensitive by Kubernetes version.
- Review release notes before applying policy in production clusters.
- Always test first on local or staging cluster nodes.

## Summary

- Memory policy is a node-level tuning lever managed via kubelet config.
- Safe rollout requires health checks and pod-level validation.
- Treat node tuning as controlled operational change with rollback options.

## Next Lesson

Continue with other cluster administration tasks in `3.2-administer-a-cluster` and apply the same validate-before-scale pattern.

## Transcript (Simple Spoken English)

### [0:00-0:45] Hook

In this lesson, we will tune memory behavior on a Kubernetes node. By the end, you will change kubelet policy safely and confirm workloads still run correctly.

### [0:45-2:30] Concept in plain words

Think of node memory like seats in a bus. If seat assignment is random, important passengers may not get consistent seats. Memory policy helps kubelet make allocation behavior more predictable for sensitive workloads.

### [2:30-7:30] Hands-on walkthrough

First, confirm your node is healthy. Next, inspect current kubelet config on that node. Then set `memoryManagerPolicy: "Static"` in `config.yaml`. Restart kubelet and verify node health from the control plane. Finally, deploy a small pod with fixed memory request and limit to validate that scheduling and runtime behavior remain healthy.

### [7:30-9:00] Troubleshooting

If the node goes `NotReady`, usually YAML formatting is wrong. If kubelet does not start, check `journalctl` immediately. If your pod does not schedule, verify allocatable memory and node taints. Always validate one node first before rolling out cluster-wide.

### [9:00-10:00] Recap

You learned how to tune node memory policy through kubelet config, restart kubelet safely, and verify cluster and pod health. This is exactly the pattern used in production: change, validate, then scale rollout.
