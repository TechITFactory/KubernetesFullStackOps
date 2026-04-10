# 4.4.1 Apply Pod Security Standards at the Cluster Level

- Summary: Enforce Pod Security Standards globally and verify denied workloads.
- Content:
  - Cluster-wide defaults reduce misconfiguration risk.
  - Start with `warn/audit`, then move to `enforce`.
  - Test with an intentionally non-compliant pod.
- Lab:

## Lab Steps (Linux)

```bash
kubectl label --overwrite ns default pod-security.kubernetes.io/enforce=restricted
kubectl label --overwrite ns default pod-security.kubernetes.io/audit=restricted
kubectl label --overwrite ns default pod-security.kubernetes.io/warn=restricted
```

Create non-compliant test pod:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pss-deny-test
spec:
  containers:
    - name: c
      image: nginx:1.27
      securityContext:
        privileged: true
EOF
```

Success signal: pod creation denied by policy.
Failure signal: pod runs despite privileged settings.

EKS extension: same namespace labels work on EKS with supported versions.
