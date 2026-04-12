# Pod Lifecycle — teaching transcript

## Intro

A Pod’s **phase** (`Pending`, `Running`, `Succeeded`, `Failed`, `Unknown`) is a coarse summary of lifecycle: **Pending** usually means not yet scheduled or images/volumes not ready; **Running** means at least one container has started (you can still be not **Ready**); **Succeeded** / **Failed** apply when all containers stop and **restartPolicy** allows termination. **Container states** add detail: **Waiting** (reason like `ContainerCreating`), **Running**, **Terminated** (exit code, signal). **`restartPolicy`** tells kubelet what to do when a container exits: **`Always`** (default) restarts except on successful completion of pods that terminate; **`OnFailure`** restarts only on failure; **`Never`** never restarts. **Readiness**, **liveness**, and **startup** probes are different: **readiness** controls whether the Pod receives Service traffic; **liveness** can restart a container kubelet thinks is dead; **startup** protects slow-boot apps from liveness killing them too early. This lesson focuses on **status fields** and events; probes are configured in YAML but interpreted through **conditions** like `Ready`.

**Prerequisites**

- [Part 2 prerequisites](../../../README.md#prerequisites-met-read-this-before-21)
- Optional: [1.1.3 dev-local workspace](../../../../01-Local-First-Operations/1.1-learning-environment/1.1.3-local-development-clusters/README.md) if you use a dedicated namespace (`NS=dev-local` works with the verify script)

## Learning objective

- Read **`.status.phase`** and **Pod conditions** and relate them to scheduling and container startup.
- Map **container states** and **`restartPolicy`** to kubelet behavior.
- Distinguish **readiness** from **liveness** from **startup** probes by effect on traffic and restarts.
- Use `kubectl describe` and **events** to explain why a Pod is not `Ready`.

## Why this matters

Incidents often start as “pod not ready.” On-call engineers read phase, conditions, and the event stream before touching the app. Confusing **CrashLoopBackOff** with a **scheduling** problem wastes minutes.

## Flow of this lesson

```
  Pod created (Pending)
        │
        ▼
  Scheduled → Initialized → containers start
        │
        ▼
  Running (phase)  ──may still be──► Ready=False (readiness / startup)
        │
        ▼
  Succeeded or Failed (terminal phases for batch-style pods)
```

**Say:**

Phase is the headline; **Conditions** are the paragraphs. Probes bridge application health into those conditions—without probes, “Running” often implies ready for simple demos only.

## Concepts (short theory)

- **Phase** can mislead: `Running` + `Ready=False` is common when readiness fails.
- **Conditions** such as `PodScheduled`, `Initialized`, `ContainersReady`, and `Ready` carry the detailed truth; `Ready=True` is what Services use for endpoints.
- **`restartPolicy`** interacts with probe failures and exit codes in real apps; the demo uses a simple sleep loop without probes.

---

## Step 1 — Apply the demo Pod and wait for Ready

**What happens when you run this:**

`kubectl apply` creates a Pod in `default` (or your current namespace). The scheduler places it; kubelet pulls `busybox:1.36`, starts `sleep 3600`. With **no readiness probe**, kubelet sets **Ready** once the container is running.

**Say:**

I narrate that **Pending** might flash while the image pulls—watch Events if it sticks.

**Run:**

```bash
kubectl apply -f yamls/pod-lifecycle-demo.yaml
kubectl wait --for=condition=Ready pod/pod-lifecycle-demo --timeout=120s
kubectl get pod pod-lifecycle-demo -o wide
```

**Expected:** `PHASE=Running`, `READY=1/1`, node name populated.

---

## Step 2 — Run the verify script (optional namespace)

**What happens when you run this:**

The script asserts the Pod exists and `Ready=True`—automated check for CI or self-study.

**Say:**

I mention `NS=dev-local` so viewers with a dev namespace do not fight the default.

**Run:**

```bash
chmod +x scripts/verify-pod-lifecycle-lesson.sh
./scripts/verify-pod-lifecycle-lesson.sh
# Other namespace: NS=dev-local ./scripts/verify-pod-lifecycle-lesson.sh
```

**Expected:** Script exits successfully.

---

## Troubleshooting

- **`Pending` forever** → describe pod; check **Events** for scheduling, image pull, or volume errors
- **`Running` but `READY 0/1`** → readiness probe failing or not all containers ready; this demo has one container—check **Conditions**
- **`CrashLoopBackOff`** → container exits; read **Last State** in `describe`; contrast with **ImagePullBackOff**
- **`Unknown` phase** → node lost contact; investigate **node** and **kubelet** health
- **`restartPolicy: Never` pod stays Failed** → expected after failure; delete or fix spec
- **Verify script fails** → wrong namespace; set `NS` or apply demo into `default`

## Video close — fast validation

**What happens when you run this:**

Wide columns show node placement; the `sed` slice shows the **Conditions** block for teaching review.

**Say:**

I use this as the closing board shot so the audience reads **Ready** alongside **phase**.

```bash
kubectl get pod pod-lifecycle-demo -o wide
kubectl describe pod pod-lifecycle-demo | sed -n '/Conditions:/,/Events:/p'
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/pod-lifecycle-demo.yaml` | Single-container demo Pod |
| `yamls/failure-troubleshooting.yaml` | Common failure patterns for drills |
| `scripts/verify-pod-lifecycle-lesson.sh` | Confirms Pod exists and `Ready=True` |

## Cleanup

**Run:**

```bash
kubectl delete -f yamls/pod-lifecycle-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.1.2 Init Containers](../03-init-containers/README.md)
