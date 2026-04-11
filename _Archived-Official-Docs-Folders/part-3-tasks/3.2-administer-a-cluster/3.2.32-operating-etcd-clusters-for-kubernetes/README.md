# 3.2.32 Operating etcd Clusters for Kubernetes

- Summary: Perform core etcd operational checks for Kubernetes control-plane reliability.
- Content:
  - etcd health directly impacts API server availability.
  - Regular snapshot/restore drills are mandatory.
  - Validate member health and endpoint status.
- Lab:

```bash
export ETCDCTL_API=3
sudo etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
  endpoint health
```

Take snapshot:

```bash
sudo etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
  snapshot save /tmp/etcd-snapshot.db
```

Success signal: healthy endpoints and valid snapshot created.
Failure signal: endpoint health failure or snapshot command error.
