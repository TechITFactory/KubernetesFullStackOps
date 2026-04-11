# 2.2.9 Mixed Version Proxy — teaching transcript

## Intro

Advanced topic: **version skew** and upgrade windows — connect policy docs to live `kubectl version` / node kubelet versions.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** The notes manifest targets **`kube-system`** — if apply is forbidden, review the YAML locally or copy into a namespace you can write.

## Lab — Quick Start

**What happens when you run this:**  
- `kubectl version` — client + server gitVersion.  
- Nodes wide — kubelet versions in status.  
- Apply notes manifest for in-cluster reference.

```bash
kubectl version
kubectl get nodes -o wide
kubectl apply -f yamls/mixed-version-proxy-notes.yaml
```

**Expected:**  
Skew visible between components; notes manifest applies (namespace must exist per YAML).

## Video close — fast validation

**What happens when you run this:**  
Repeat version; custom-columns kubelet versions; recent events.

```bash
kubectl version
kubectl get nodes -o custom-columns=NAME:.metadata.name,KUBELET:.status.nodeInfo.kubeletVersion
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/mixed-version-proxy-notes.yaml` | Policy notes |
| `yamls/failure-troubleshooting.yaml` | Skew / upgrade |

## Next

[2.4 Workloads](../../2.4-workloads/README.md) or [2.3 Containers](../../2.3-containers/README.md)
