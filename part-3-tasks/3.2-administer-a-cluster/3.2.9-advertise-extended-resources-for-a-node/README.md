# 3.2.9 Advertise Extended Resources for a Node

- Summary: Advertise custom node resources for specialized workload scheduling.
- Content:
  - Extended resources represent devices/features outside core CPU/memory.
  - Scheduler can target workloads requesting those resources.
  - Validate allocatable resource keys on target nodes.
- Lab:

```bash
kubectl describe node <node-name> | grep -A20 -i Allocatable
kubectl get node <node-name> -o yaml | grep -i "example.com" -n
```

Manual capacity patch (lab only):

```bash
kubectl patch node <node-name> --type='json' -p='[{"op":"add","path":"/status/capacity/example.com~1fpga","value":"1"}]'
```

Success signal: node advertises extended resource key/value.
Failure signal: resource not visible in node status/allocatable.
