# 4.4.2 Apply Pod Security Standards at the Namespace Level

- Summary: Apply different Pod Security levels per namespace based on risk.
- Content:
  - Namespace-level control enables gradual hardening.
  - Use stricter policy for production namespaces first.
  - Validate allowed and denied pod behavior in each namespace.
- Lab:

## Lab Steps (Linux)

```bash
kubectl create ns team-dev
kubectl create ns team-prod
kubectl label --overwrite ns team-dev pod-security.kubernetes.io/enforce=baseline
kubectl label --overwrite ns team-prod pod-security.kubernetes.io/enforce=restricted
kubectl get ns --show-labels | grep team-
```

Run quick policy test:

```bash
kubectl run test-dev -n team-dev --image=nginx:1.27
kubectl run test-prod -n team-prod --image=nginx:1.27 --overrides='{"spec":{"containers":[{"name":"test-prod","image":"nginx:1.27","securityContext":{"privileged":true}}]}}'
```

Success signal: relaxed pod allowed in dev, denied in prod (for unsafe settings).
Failure signal: policies behave the same in both namespaces.

EKS extension: namespace-level policy is recommended for phased platform rollout.
