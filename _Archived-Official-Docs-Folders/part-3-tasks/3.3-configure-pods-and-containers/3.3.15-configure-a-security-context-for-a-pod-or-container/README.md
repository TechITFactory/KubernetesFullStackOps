# 3.3.15 Configure a Security Context for a Pod or Container

- Summary: Harden pod/container runtime with security context settings.
- Content:
  - Security context controls privilege and filesystem behavior.
  - Start with non-root + no privilege escalation defaults.
  - Validate effective settings in running pod spec.
- Lab:

```bash
cat <<'EOF' > security-context.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secctx-pod
spec:
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: app
      image: nginx:1.27
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: false
EOF
kubectl apply -f security-context.yaml
kubectl get pod secctx-pod
kubectl get pod secctx-pod -o yaml | grep -A8 -i securityContext
```

Success signal: pod runs with intended security context.
Failure signal: pod rejected due to policy/runtime mismatch.

EKS extension: enforce via Pod Security Admission and policy engine.
