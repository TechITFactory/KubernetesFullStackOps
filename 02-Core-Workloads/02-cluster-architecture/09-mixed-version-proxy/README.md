# 2.2.9 Mixed Version Proxy — teaching transcript

## Intro

During a Kubernetes upgrade, the control plane and nodes are not all updated simultaneously — there is a window where multiple versions run in the same cluster. The **mixed version proxy** is the mechanism that lets the API server route requests to the correct version during this window.

Kubernetes has a formal **version skew policy**:
- `kubectl` must be within **1 minor version** of the API server (newer or older)
- `kubelet` must be within **2 minor versions** of the API server (older only — kubelet cannot be newer than the API server)
- Control plane components (kube-scheduler, kube-controller-manager) must match the API server minor version exactly

During a rolling control plane upgrade, multiple API server replicas briefly run different versions. The mixed version proxy allows any API server to forward requests to another replica that serves a resource the requesting server does not yet support.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

> **RBAC note:** `yamls/mixed-version-proxy-notes.yaml` targets `kube-system`. On clusters with restrictive RBAC, this write may return `Forbidden`. If so, read the YAML locally or apply it to the `default` namespace with `-n default`.

---

## Flow of this lesson

```
  [ Step 1 ]                    [ Step 2 ]
  Check live version   →        Apply reference notes
  information                   (in-cluster ConfigMap)
  (kubectl + nodes)
```

**Say:** "Two steps. First we look at the live version information available through kubectl — client version, server version, and kubelet version on each node. This is the skew audit you run before any upgrade. Then we apply reference notes as a ConfigMap."

---

## Step 1 — Check version skew

**What happens when you run this:**
`kubectl version` shows client and server versions side by side. `kubectl get nodes -o wide` shows the kubelet version on each node in the VERSION column. Together, these give you the full skew picture.

**Say:** "The output I'm looking for: client minor version within 1 of the server, node kubelet minor version within 2 of the server, and all nodes at the same kubelet version if I'm not mid-upgrade. If any node shows a kubelet version more than 2 minor versions behind the API server, that node needs to be upgraded before the next control plane upgrade."

**Run:**

```bash
kubectl version
kubectl get nodes -o wide
```

**Expected:**
Client and server versions visible. VERSION column on nodes shows kubelet versions. All versions within the supported skew range.

---

## Step 2 — Inspect kubelet versions with custom columns

**What happens when you run this:**
`kubectl get nodes -o custom-columns` extracts just the node name and kubelet version into a clean table. This is easier to read than the full wide output when you have many nodes.

**Say:** "Custom columns is how I audit version skew across a large node pool quickly. I can pipe this to sort and grep to find any node running an old kubelet version. Before every control plane upgrade, I run this, confirm all nodes are within the skew policy, then proceed."

**Run:**

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,KUBELET:.status.nodeInfo.kubeletVersion
```

**Expected:**
Clean two-column table: NAME and KUBELET version for every node.

---

## Step 3 — Apply reference notes

**What happens when you run this:**
`kubectl apply -f yamls/mixed-version-proxy-notes.yaml` creates a ConfigMap in `kube-system` with version skew policy documentation. If your cluster blocks writes to `kube-system`, add `-n default` to apply to the default namespace instead.

**Say:** "I store the skew policy as a ConfigMap so any engineer on the cluster can read it with kubectl without needing a browser. It's a small habit that makes the policy discoverable."

**Run:**

```bash
kubectl apply -f yamls/mixed-version-proxy-notes.yaml
```

**Expected:**
`configmap/mixed-version-proxy-notes created` or `unchanged`. If `Forbidden`, run with `-n default`.

---

## Troubleshooting

- **`Error from server (NotFound)` after upgrading API server`** → a kubelet version more than 2 minor versions old cannot register correctly with a newer API server; upgrade the kubelet on the affected node.
- **`kubectl commands fail after API server upgrade`** → your local kubectl may be more than 1 minor version away from the new API server; upgrade kubectl to match; download the matching version from the Kubernetes release page.
- **`Nodes stuck at old version after control plane upgrade`** → the control plane upgrade does not upgrade kubelets automatically; drain each node, upgrade the kubelet package (`apt-get install kubelet=<version>`), uncordon.
- **`Mixed version proxy errors in API server logs`** → check `kubectl logs -n kube-system -l component=kube-apiserver` for proxy routing failures; these typically resolve once all API server replicas are on the same version.
- **`ConfigMap apply Forbidden on kube-system`** → apply with `-n default` instead; the content is unchanged; update the lesson steps accordingly for your cluster's RBAC policy.

---

## Learning objective

- State the Kubernetes version skew policy for kubectl, kubelet, and control plane components.
- Use `kubectl version` and custom-columns to audit version skew before an upgrade.
- Explain what the mixed version proxy does and when it is active.

## Why this matters

Upgrade failures caused by version skew violations are preventable with a 30-second audit. Kubelet versions that are too far behind the API server cause silent failures — pods that don't get scheduled, node conditions that don't update, logs that can't be streamed. The skew policy exists for a reason; checking it before every upgrade is a production habit.

---

## Video close — fast validation

**What happens when you run this:**
Client and server version; clean kubelet version table; recent events. All read-only.

**Say:** "Version, custom-columns kubelet audit, events. If the skew is within policy and events are clean, the cluster is ready for the next upgrade step."

```bash
kubectl version
kubectl get nodes -o custom-columns=NAME:.metadata.name,KUBELET:.status.nodeInfo.kubeletVersion
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/mixed-version-proxy-notes.yaml` | Version skew policy reference ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Skew violation and upgrade order hints |

---

## Next

[2.4 Workloads](../../2.4-workloads/README.md) or [2.3 Containers](../../2.3-containers/README.md)
