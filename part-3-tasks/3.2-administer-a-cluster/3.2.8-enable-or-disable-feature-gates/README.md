# 3.2.8 Enable Or Disable Feature Gates

- Summary: Toggle Kubernetes feature gates safely and validate impact.
- Content:
  - Feature gates control alpha/beta functionality at component level.
  - Changes must be version-aware and tested in non-production first.
  - Verify component startup and API behavior after toggle.
- Lab:

```bash
kubectl version
kubectl get --raw /metrics | grep -i feature || true
sudo grep -R --line-number "feature-gates" /etc/kubernetes/manifests /var/lib/kubelet 2>/dev/null
```

Example kubelet flag:

```bash
--feature-gates=SomeFeature=true
```

Success signal: component starts healthy with intended gate state.
Failure signal: control-plane/kubelet restart loops due to invalid gate.

EKS extension: feature-gate control is limited; rely on supported managed versions/features.
