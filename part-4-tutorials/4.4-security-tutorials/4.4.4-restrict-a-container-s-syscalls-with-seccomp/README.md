# 4.4.4 Restrict a Container's Syscalls with seccomp

- Summary: Use seccomp to limit Linux syscalls available to containers.
- Content:
  - seccomp reduces kernel attack surface.
  - Runtime default profile is a safe baseline for most workloads.
  - Verify securityContext and pod events after apply.
- Lab:

## Lab Steps (Linux)

Apply pod with seccomp runtime default:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: seccomp-demo
spec:
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: main
      image: nginx:1.27
      securityContext:
        allowPrivilegeEscalation: false
EOF
kubectl get pod seccomp-demo
kubectl describe pod seccomp-demo
```

Confirm effective profile:

```bash
kubectl get pod seccomp-demo -o yaml | grep -A3 seccompProfile
```

Success signal: pod runs with `RuntimeDefault` seccomp profile.
Failure signal: admission warning/error for unsupported seccomp settings.

Cleanup:

```bash
kubectl delete pod seccomp-demo
```

EKS extension: enforce RuntimeDefault with policy tooling (for example Kyverno) after validating workload compatibility.

## Transcript

[0:00-0:30] You will harden a pod using seccomp in one manifest.  
[0:30-2:00] seccomp blocks unnecessary syscalls to reduce exploit surface.  
[2:00-7:00] Apply pod, confirm running state, inspect securityContext in YAML output.  
[7:00-9:00] If workloads break, validate required syscalls before strict enforcement.  
[9:00-10:00] RuntimeDefault is a practical baseline for production clusters.
