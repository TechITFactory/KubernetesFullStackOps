# 3.3.30 Enforce Pod Security Standards with Namespace Labels

- Summary: Enforce Pod Security Standards per namespace using built-in labels.
- Content:
  - Namespace labels enable `enforce`, `audit`, and `warn` modes.
  - Start with non-blocking modes, then enforce.
  - Validate with compliant and non-compliant pods.
- Lab:

```bash
kubectl create ns pss-lab
kubectl label --overwrite ns pss-lab pod-security.kubernetes.io/enforce=restricted
kubectl label --overwrite ns pss-lab pod-security.kubernetes.io/warn=restricted
kubectl label --overwrite ns pss-lab pod-security.kubernetes.io/audit=restricted
kubectl get ns pss-lab --show-labels
```

Test denied pod:

```bash
kubectl run bad-pod -n pss-lab --image=nginx:1.27 --overrides='{"spec":{"containers":[{"name":"bad-pod","image":"nginx:1.27","securityContext":{"privileged":true}}]}}'
```

Success signal: non-compliant pod denied by policy.
Failure signal: privileged pod allowed in restricted namespace.
