# 3.2.16 Configure a kubelet Image Credential Provider

- Summary: Configure kubelet image credential provider for dynamic registry auth.
- Content:
  - Credential providers avoid static secret distribution on nodes.
  - Useful for short-lived credentials (for example cloud registries).
  - Validate kubelet plugin config and image pull behavior.
- Lab:

```bash
sudo grep -i credentialprovider /var/lib/kubelet/config.yaml
sudo ls -la /etc/kubernetes/image-credential-provider/ 2>/dev/null
sudo systemctl restart kubelet
kubectl get nodes
```

Pull-test workload:

```bash
kubectl run pull-test --image=<private-image> --restart=Never
kubectl describe pod pull-test | grep -i -E "pull|image"
```

Success signal: private image pulls without static pull secret.
Failure signal: image pull auth errors continue.
