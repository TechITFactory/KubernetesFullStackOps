# 3.2.6 Install a Network Policy Provider

- Summary: Install and verify a CNI/provider that enforces NetworkPolicy.
- Content:
  - NetworkPolicy objects require provider support to enforce rules.
  - Validate provider readiness before policy testing.
  - Confirm deny/allow behavior using test pods.
- Lab:

```bash
kubectl get pods -n kube-system
kubectl get daemonset -A | grep -Ei "calico|cilium|weave|antrea|aws-node"
kubectl api-resources | grep -i networkpolicy
```

Then run policy enforcement test:

```bash
kubectl create ns np-check
kubectl run server -n np-check --image=nginx:1.27 --labels=app=server
kubectl run client -n np-check --image=busybox:1.36 --restart=Never -- sleep 3600
```

Success signal: provider pods healthy and policy tests enforce as expected.
Failure signal: policies apply but traffic behavior unchanged.

EKS extension: use VPC CNI + supported network policy engine setup.
