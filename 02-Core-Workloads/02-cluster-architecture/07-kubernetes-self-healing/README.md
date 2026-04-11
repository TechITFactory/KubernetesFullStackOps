# 2.2.7 Kubernetes Self-Healing — teaching transcript

## Intro

"Kubernetes is self-healing" is accurate but incomplete. It's self-healing **within the boundaries of what controllers and probes can detect and fix**. It does not protect against bad deployments, misconfigured health checks, or stateful data loss.

Self-healing has three layers:
- **Controllers** — detect when actual pod count diverges from desired and create replacements
- **Probes** — liveness probes detect when a running container is stuck and restart it; readiness probes prevent broken pods from receiving traffic
- **Scheduler** — when a node fails, the scheduler places evicted pods on healthy nodes

What self-healing does **not** do: recover data written to a pod's ephemeral filesystem, prevent a bad image from crashing in a loop, or fix a liveness probe that is misconfigured to always fail.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

---

## Flow of this lesson

```
  [ Step 1 ]              [ Step 2 ]                [ Step 3 ]
  Run script       →      Delete a pod,      →      Clean up
  (apply demo             watch controller
  Deployment)             replace it
```

**Say:** "Three steps. Apply the demo Deployment, then force the self-healing loop by deleting one pod and watching the controller bring it back. This makes the abstract concept concrete — you see the replacement pod appear in real time."

---

## Step 1 — Apply the demo Deployment

**What happens when you run this:**
`self-healing-demo.sh` creates namespace `self-healing-demo` and a Deployment inside it. The script then lists the Deployment and pods so you can confirm the desired state is met.

**Say:** "The script applies the manifest and immediately shows you the result. Notice READY is 2/2 — the controller has already reconciled toward the desired replica count. Now we're going to break that state on purpose and watch it heal."

**Run:**

```bash
chmod +x scripts/*.sh
./scripts/self-healing-demo.sh
kubectl get deploy,pods -n self-healing-demo -l app=self-healing-demo
```

**Expected:**
Deployment `READY 2/2`. Two pods in `Running` state.

---

## Step 2 — Trigger and observe self-healing

**What happens when you run this:**
`kubectl delete pod` removes one pod with `--wait=false` so the command returns immediately. `kubectl get pods -w` then streams pod events — you see the deleted pod enter `Terminating` and a new pod appear in `Pending` then `Running`. The `-l` label selector targets only the demo pods.

**Say:** "I'm deleting one pod. Without Kubernetes self-healing, it would just be gone. With it, the ReplicaSet controller detects the drop from 2 to 1, computes the gap, and issues a create request. The kubelet on a node picks up the new pod spec and starts the container. The whole recovery takes a few seconds. Press Ctrl+C once you see the new pod Running."

**Run:**

```bash
kubectl delete pod -n self-healing-demo -l app=self-healing-demo --wait=false
kubectl get pods -n self-healing-demo -l app=self-healing-demo -w
```

**Expected:**
One pod `Terminating`, new pod appears `Pending` → `ContainerCreating` → `Running`. Total count stays at 2.

---

## Step 3 — Clean up

**What happens when you run this:**
Deleting the namespace removes the Deployment, ReplicaSet, and all Pods in one operation. `--ignore-not-found` prevents an error on re-runs.

**Say:** "Namespace delete is the clean way to remove a demo — one command removes everything. If you delete only the Deployment, the namespace stays behind empty. Either is fine, but namespace delete is complete."

**Run:**

```bash
kubectl delete namespace self-healing-demo --ignore-not-found
```

**Expected:**
`namespace "self-healing-demo" deleted`.

---

## Troubleshooting

- **`Pod not replaced after deletion`** → confirm the Deployment and ReplicaSet still exist; if you deleted the Deployment, the RS is also gone and there is nothing to reconcile; check `kubectl get rs -n self-healing-demo`.
- **`Pod in CrashLoopBackOff, not healing`** → self-healing restarts the container but cannot fix a broken image or bad configuration; check `kubectl logs <pod>` for the application error; fix the image or config, then roll out a new Deployment revision.
- **`Liveness probe keeps killing a healthy container`** → the probe is misconfigured; check `kubectl describe pod <name>` for `Liveness probe failed` events; verify the probe endpoint, initial delay, and timeout match what the application actually exposes.
- **`Pod not rescheduled after node failure`** → if the node is in `Unknown` state, pods stay `Terminating` for up to 5 minutes before the controller force-deletes them; this delay is controlled by `--pod-eviction-timeout`; on cloud clusters, the node lifecycle controller evicts faster.
- **`Readiness probe failing, pod getting no traffic`** → this is correct behavior — readiness failure removes the pod from Service endpoints; check `kubectl describe pod` for the probe failure reason and fix the application or probe configuration.

---

## Learning objective

- Describe the three layers of Kubernetes self-healing (controllers, probes, scheduler).
- Demonstrate that deleting a pod triggers controller reconciliation and produces a replacement.
- Explain two things self-healing cannot fix.

## Why this matters

Self-healing is often treated as a reason not to monitor. It isn't. Controllers replace pods, but they don't fix broken images or bad configurations — they just restart the crash loop faster. Understanding what self-healing covers and what it doesn't tells you where you still need alerts, liveness probes, and proper rollout strategies.

---

## Video close — fast validation

**What happens when you run this:**
Delete one pod without waiting; then watch pods stream until the replacement is Running. Read-only after the delete.

**Say:** "I delete, then watch. Within a few seconds the replacement is Running. That's the controller reconcile loop completing one cycle. If you timed it, that's how fast your cluster recovers from a single pod failure."

```bash
kubectl get deploy,pods -n self-healing-demo -l app=self-healing-demo -o wide
kubectl delete pod -n self-healing-demo -l app=self-healing-demo --wait=false
kubectl get pods -n self-healing-demo -l app=self-healing-demo -w
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/self-healing-demo.sh` | Apply demo Deployment and list resources |
| `yamls/self-healing-demo.yaml` | Demo Deployment in self-healing-demo namespace |
| `yamls/failure-troubleshooting.yaml` | Probe and rollout failure hints |

---

## Cleanup

```bash
kubectl delete namespace self-healing-demo --ignore-not-found
```

---

## Next

[2.2.8 Garbage collection](../2.2.8-garbage-collection/README.md)
