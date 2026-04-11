# 2.2.5 Cloud Controller Manager — teaching transcript

## Intro

**CCM** splits cloud-provider logic from core control plane. Many bare-metal / kind clusters have **no** CCM pod — that is normal.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

## Lab — Quick Start

**What happens when you run this:**  
- Script greps `kube-system` for cloud-controller patterns.  
- You grep all namespaces (broader).  
- Apply responsibilities reference manifest.

```bash
chmod +x scripts/*.sh
./scripts/inspect-cloud-controller-manager.sh
kubectl get pods -A | grep -i cloud-controller || true
kubectl apply -f yamls/cloud-controller-manager-responsibilities.yaml
```

**Expected:**  
You can state whether CCM appears; ConfigMap/notes apply for teaching review.

## Video close — fast validation

**What happens when you run this:**  
Nodes; CCM grep; all Services (can be long).

```bash
kubectl get nodes -o wide
kubectl get pods -A | grep -Ei 'cloud-controller|ccm' || true
kubectl get svc -A
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-cloud-controller-manager.sh` | CCM discovery |
| `yamls/cloud-controller-manager-responsibilities.yaml` | Reference |
| `yamls/failure-troubleshooting.yaml` | Provider integration |

## Next

[2.2.6 About cgroup v2](../2.2.6-about-cgroup-v2/README.md)
