# 3.2.33 Reserve Compute Resources for System Daemons

- Summary: Reserve node resources for system daemons to protect cluster stability.
- Content:
  - Without reserved resources, system services can starve under workload pressure.
  - kubelet supports `systemReserved` and `kubeReserved`.
  - Validate node allocatable values after config change.
- Lab:

```bash
sudo grep -i -E "systemReserved|kubeReserved|evictionHard" /var/lib/kubelet/config.yaml
kubectl describe node <node-name> | grep -A8 -i Allocatable
```

Example kubelet config snippet:

```yaml
systemReserved:
  cpu: "200m"
  memory: "512Mi"
kubeReserved:
  cpu: "200m"
  memory: "512Mi"
```

Success signal: allocatable reflects reservation and node remains healthy.
Failure signal: kubelet fails to start after config change.

EKS extension: implement via managed node bootstrap/user data patterns.
