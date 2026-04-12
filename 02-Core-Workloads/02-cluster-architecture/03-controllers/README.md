# Controllers — teaching transcript

## Intro

A controller is a control loop that watches the API server for a specific resource type, compares **desired state** (what you declared) to **actual state** (what exists), and takes action to close the gap. This pattern — called **reconciliation** — is how everything in Kubernetes works.

The Deployment controller watches Deployment objects and ensures a matching ReplicaSet exists. The ReplicaSet controller watches ReplicaSets and ensures the correct number of Pods exist. The Job controller watches Jobs and creates Pods until the completion count is met. Each controller is responsible for one resource type and one reconcile loop.

Controllers run inside `kube-controller-manager` on the control plane for built-in types, or as separate pods for custom controllers. They write back to the API server — they never touch nodes or containers directly. The kubelet, not the controller, is what actually starts and stops containers.

**Prerequisites:** [Part 1](../../../01-Local-First-Operations/README.md).

---

## Flow of this lesson

```
  [ Step 1 ]              [ Step 2 ]                [ Step 3 ]
  Run script       →      Observe controller  →      Clean up
  (apply demo             reconcile:
  Deployment)             delete a pod,
                          watch it come back
```

**Say:** "Three steps. The script applies a Deployment, which kicks off the controller reconcile loop. Then we manually delete one pod and watch the controller bring it back — that's the reconcile loop in action. Then we clean up."

---

## Step 1 — Apply the demo Deployment

**What happens when you run this:**
`controller-reconciliation-demo.sh` creates namespace `controller-demo` and a two-replica Deployment inside it. The Deployment controller creates a ReplicaSet; the ReplicaSet controller creates two Pods. The script then lists the resulting resources.

**Say:** "I applied one object — a Deployment. But three things were created: a ReplicaSet and two Pods, each one created by a different controller reacting to the previous object. That cascade of reactions is the reconcile loop in action."

**Run:**

```bash
chmod +x scripts/*.sh
./scripts/controller-reconciliation-demo.sh
kubectl get deploy,pods -n controller-demo -l app=controller-demo
```

**Expected:**
Deployment shows `2/2 READY`. Two pods in `Running` state.

---

## Step 2 — Observe the reconcile loop

**What happens when you run this:**
`kubectl delete pod` removes one pod immediately. The ReplicaSet controller detects that actual count (1) is below desired (2) and creates a replacement. The `-w` flag streams pod events so you can see the new pod appear in real time.

**Say:** "Watch what happens: the pod disappears, and within seconds a new one appears. I didn't do anything. The ReplicaSet controller noticed the count dropped, computed the gap, and issued a pod creation request to the API server. The kubelet on a node picked that up and started the container. That whole sequence takes about two seconds."

**Run:**

```bash
kubectl delete pod -n controller-demo -l app=controller-demo --wait=false
kubectl get pods -n controller-demo -l app=controller-demo -w
```

**Expected:**
One pod enters `Terminating`, a new pod appears in `Pending` then `Running`. Total count returns to 2. Press Ctrl+C to stop watching.

---

## Step 3 — Clean up

**What happens when you run this:**
Deleting the namespace removes everything inside it. `--ignore-not-found` prevents an error if the namespace was already removed.

**Say:** "I delete the namespace, not the Deployment. Deleting the namespace triggers a cascade through ownerReferences: Deployment gone, ReplicaSet gone, Pods gone. The same reconcile pattern working in reverse."

**Run:**

```bash
kubectl delete namespace controller-demo --ignore-not-found
```

**Expected:**
`namespace "controller-demo" deleted`.

---

## Troubleshooting

- **`Deployment not reconciling`** → check `kubectl describe deploy <name>` for conditions; check `kubectl get events -n <namespace>` for controller errors; if kube-controller-manager is unhealthy, check `kubectl logs -n kube-system -l component=kube-controller-manager`.
- **`Pod not recreated after deletion`** → confirm the ReplicaSet still exists with `kubectl get rs -n <namespace>`; if the RS was deleted or its selector changed, the controller has no target to reconcile toward.
- **`Deployment stuck at old replica count`** → the controller may be blocked by a PodDisruptionBudget; check `kubectl get pdb -n <namespace>` and whether `ALLOWED DISRUPTIONS` is 0.
- **`Too many ReplicaSets accumulating`** → `spec.revisionHistoryLimit` (default 10) controls how many old ReplicaSets are retained; lower it if etcd storage is growing.
- **`Custom controller not reconciling`** → check the controller pod logs for watch errors or permission denials; the controller needs RBAC to read and write the resources it manages.

---

## Learning objective

- Explain the reconcile loop: watch, compare desired vs actual, act.
- Name three built-in controllers and which resource type each manages.
- Demonstrate that deleting a pod triggers controller reconciliation and produces a replacement.

## Why this matters

Every "Kubernetes fixed itself" story is a controller doing its job. Every "Kubernetes isn't doing what I told it to" story is a controller blocked or confused. Understanding reconciliation lets you ask the right question: which controller is responsible, what desired state did I declare, and what actual state does it see? That framing resolves most workload issues without guessing.

---

## Video close — fast validation

**What happens when you run this:**
State check on Deployment and pods; Deployment describe showing controller events; recent namespace events. All read-only.

**Say:** "Describe deploy shows the Events section at the bottom — that's where the controller logs its actions: scaling up, scaling down, creating ReplicaSets. It's the audit trail for everything the controller did."

```bash
kubectl get deploy,pods -n controller-demo -l app=controller-demo
kubectl describe deploy controller-demo -n controller-demo | sed -n '1,80p'
kubectl get events -n controller-demo --sort-by=.lastTimestamp | tail -n 20
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/controller-reconciliation-demo.sh` | Apply demo Deployment and list resources |
| `yamls/controller-demo-deployment.yaml` | Two-replica nginx Deployment in controller-demo namespace |
| `yamls/failure-troubleshooting.yaml` | Rollout and selector mismatch hints |

---

## Cleanup

```bash
kubectl delete namespace controller-demo --ignore-not-found
```

---

## Next

[2.2.4 Leases](../04-leases/README.md)
