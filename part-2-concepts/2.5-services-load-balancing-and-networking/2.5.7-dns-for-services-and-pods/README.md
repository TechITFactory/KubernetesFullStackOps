# 2.5.7 DNS for Services and Pods

- Summary: DNS for Services and Pods is a core Kubernetes concept that needs to be understood both declaratively and operationally.
- Content: This section explains dns for services and pods in practical Kubernetes terms and ties it back to observable cluster behavior.
- Lab: Review the assets here, apply the sample manifest if provided, and inspect the resulting state with kubectl.

## Assets

- `scripts/inspect-2-5-7-dns-for-services-and-pods.sh`
- `yamls/2-5-7-dns-for-services-and-pods-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/2-5-7-dns-for-services-and-pods-notes.yaml
bash scripts/inspect-2-5-7-dns-for-services-and-pods.sh
```

## Expected output

- ConfigMap `2-5-7-dns-for-services-and-pods-notes` in `kube-system`; CoreDNS/kube-dns pods reachable in `kube-system`.

## Video close - fast validation

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns 2>/dev/null || kubectl get pods -n kube-system | grep -i coredns
bash scripts/inspect-2-5-7-dns-for-services-and-pods.sh
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common CoreDNS loops, stub/upstream resolver issues, and cluster domain search path mistakes.
