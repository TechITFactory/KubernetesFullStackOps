# 2.5.10 Networking on Windows

- Summary: Networking on Windows is a core Kubernetes concept that needs to be understood both declaratively and operationally.
- Content: This section explains networking on windows in practical Kubernetes terms and ties it back to observable cluster behavior.
- Lab: Review the assets here, apply the sample manifest if provided, and inspect the resulting state with kubectl.

## Assets

- `yamls/2-5-10-networking-on-windows-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/2-5-10-networking-on-windows-notes.yaml
kubectl get cm -n kube-system 2-5-10-networking-on-windows-notes -o name
kubectl get nodes -o wide 2>/dev/null | head -n 20
```

## Expected output

- ConfigMap `2-5-10-networking-on-windows-notes` in `kube-system`; Windows nodes appear with `OS-IMAGE` containing Windows when present.

## Video close - fast validation

```bash
kubectl get nodes -l kubernetes.io/os=windows 2>/dev/null || kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.nodeInfo.operatingSystem}{"\n"}{end}'
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common Windows kube-proxy/CNI version skew, host-gw/VXLAN mismatches, and Service datapath differences vs Linux.
