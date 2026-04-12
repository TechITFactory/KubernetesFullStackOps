# Cloud Controller Manager — teaching transcript

## Intro

The **Cloud Controller Manager (CCM)** separates cloud-provider-specific logic from the core Kubernetes control plane. Before CCM existed, cloud provider code lived inside `kube-controller-manager`, meaning every cloud vendor had to maintain a fork of the Kubernetes core. CCM lets cloud providers ship their logic independently.

CCM runs three controllers:
- **Node controller** — registers nodes with cloud metadata (instance ID, zone, region labels), and removes nodes from the cloud when they are terminated
- **Route controller** — configures routes in the cloud VPC so pods can communicate across nodes
- **Service controller** — provisions cloud load balancers when you create a Service with `type: LoadBalancer`

On **bare-metal, kubeadm, Minikube, and kind clusters**, there is no CCM pod — that is normal. `type: LoadBalancer` Services will stay `Pending` because there is no cloud to provision a load balancer. Use MetalLB or `type: NodePort` instead.

**Prerequisites:** [Part 1](../../../01-Local-First-Operations/README.md).

---

## Flow of this lesson

```
  [ Step 1 ]                    [ Step 2 ]
  Run script             →      Apply reference notes
  (check if CCM pod            (in-cluster ConfigMap)
  exists in cluster)
```

**Say:** "Two steps. First we check whether a CCM pod is running in this cluster — the answer depends on where your cluster is hosted. Then we apply a reference ConfigMap that documents CCM responsibilities so the notes live in the cluster."

---

## Step 1 — Check for a CCM pod

**What happens when you run this:**
`inspect-cloud-controller-manager.sh` greps `kube-system` pods for cloud-controller patterns. The second command greps all namespaces — some distributions run CCM outside `kube-system`. `|| true` prevents a non-zero exit if nothing matches.

**Say:** "On a kind or minikube cluster, both greps return nothing — that's expected. On EKS, GKE, or AKS, you'd see a cloud-controller-manager pod. If you're on a bare-metal cluster with MetalLB, you'd see MetalLB pods but no CCM. Knowing whether CCM is present explains why LoadBalancer Services behave the way they do on your cluster."

**Run:**

```bash
chmod +x scripts/*.sh
./scripts/inspect-cloud-controller-manager.sh
kubectl get pods -A | grep -i cloud-controller || true
```

**Expected:**
On kind/minikube/bare-metal: no output from the grep (CCM not present — this is correct). On managed cloud clusters: one or more CCM pods listed.

---

## Step 2 — Apply the reference notes

**What happens when you run this:**
`kubectl apply -f yamls/cloud-controller-manager-responsibilities.yaml` creates a ConfigMap documenting CCM responsibilities. This is reference documentation stored in the cluster.

**Say:** "I apply this as a ConfigMap so any engineer with cluster access can read it with kubectl. It's a lightweight way to store operational notes without needing a separate wiki page."

**Run:**

```bash
kubectl apply -f yamls/cloud-controller-manager-responsibilities.yaml
```

**Expected:**
`configmap/cloud-controller-manager-responsibilities created` or `unchanged`.

---

## Troubleshooting

- **`Service type: LoadBalancer stays Pending`** → on bare-metal or kind clusters, there is no CCM to provision a load balancer; use `type: NodePort` or install MetalLB; on cloud clusters, check CCM pod logs for provisioning errors.
- **`Node missing cloud labels (topology.kubernetes.io/zone, etc.)`** → CCM node controller adds these labels; if CCM is not running or crashed, nodes won't get zone/region labels, which breaks topology-aware scheduling.
- **`CCM pod CrashLoopBackOff`** → check cloud credentials mounted into the CCM pod; expired IAM roles or missing service account bindings are common causes; check `kubectl logs -n kube-system <ccm-pod>`.
- **`grep finds nothing on a cloud cluster`** → some providers run CCM in a different namespace or with a different pod name; try `kubectl get pods -A | grep -i controller` to widen the search.

---

## Learning objective

- Explain the three controllers inside CCM and what each manages.
- State why a bare-metal or kind cluster has no CCM pod and what that means for `type: LoadBalancer` Services.
- Identify whether CCM is present in a cluster using `kubectl`.

## Why this matters

Understanding CCM explains two of the most common "why isn't this working" questions on cloud clusters: why LoadBalancer Services don't get an IP without CCM, and why nodes lack zone labels when CCM is misconfigured. On bare-metal clusters, knowing CCM is absent tells you to reach for MetalLB or NodePort from the start rather than debugging a missing pod.

---

## Video close — fast validation

**What happens when you run this:**
Nodes (to confirm cloud labels if present); CCM grep; all Services. All read-only.

**Say:** "If zone and region labels appear on nodes, CCM is working. If LoadBalancer Services show an external IP, the service controller provisioned it. If both are absent and you're on a bare-metal cluster — that's the expected state."

```bash
kubectl get nodes -o wide
kubectl get pods -A | grep -Ei 'cloud-controller|ccm' || true
kubectl get svc -A
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-cloud-controller-manager.sh` | CCM pod discovery across namespaces |
| `yamls/cloud-controller-manager-responsibilities.yaml` | Reference ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Provider integration and LoadBalancer pending hints |

---

## Next

[2.2.6 About cgroup v2](../06-about-cgroup-v2/README.md)
