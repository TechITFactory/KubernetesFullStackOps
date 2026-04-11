# 2.3.4 Container Lifecycle Hooks — teaching transcript

## Intro

**Lifecycle hooks** let kubelet run extra work at container boundaries. **postStart** fires after a container is created; it runs **asynchronously** relative to the main `ENTRYPOINT`, so you must not rely on it finishing before the primary process does meaningful work. **preStop** runs **before** the **SIGTERM** sent at the start of termination — teams use it to **drain** connections, deregister from service discovery, or sleep briefly so load balancers stop sending traffic. Hooks can use **exec** (run a command in the container namespace) or **httpGet** (HTTP probe against the container). If a hook **fails** or **times out**, Kubernetes records failure; failed **preStop** can block graceful termination within **terminationGracePeriodSeconds**, after which the container still receives SIGKILL if it has not exited.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md); cluster can pull `busybox:1.36`.

**Teaching tip:** `postStart` runs asynchronously with the main process — do not rely on strict ordering for correctness.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-2-concepts/2.3-containers/2.3.4-container-lifecycle-hooks"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  apply Pod (postStart + preStop + grace)  →  wait Ready  →  prove postStart side effect
                                                                    │
                                                                    ▼
                                              describe (optional second terminal for delete + preStop)
```

**Say:**

We prove postStart by reading a file it created; preStop is best observed by deleting the pod in another terminal while watching events, because it runs on the shutdown path.

---

## Step 1 — Apply the lifecycle hooks demo Pod

**What happens when you run this:**

`kubectl apply` creates `lifecycle-hooks-demo` with `postStart.exec` writing `/tmp/postStart-ran`, `preStop.exec` echoing and sleeping five seconds, and `terminationGracePeriodSeconds: 30`. An **httpGet** hook would call an HTTP endpoint instead of exec — same lifecycle stages, different probe mechanism.

**Say:**

**preStop** gives the app time to finish in-flight work **before** SIGTERM; if the hook sleeps too long relative to grace period, the kubelet still escalates to SIGKILL when time expires.

**Run:**

```bash
cd "$COURSE_DIR/part-2-concepts/2.3-containers/2.3.4-container-lifecycle-hooks"
kubectl apply -f yamls/lifecycle-hooks-demo.yaml
```

**Expected:**

`pod/lifecycle-hooks-demo created` or unchanged.

---

## Step 2 — Wait until the Pod is Ready

**What happens when you run this:**

`kubectl wait` blocks until Ready — read-only on the API aside from wait.

**Say:**

postStart may still be racing the main `sleep 3600`; for this demo we only need the container filesystem ready enough for `exec cat`.

**Run:**

```bash
kubectl wait --for=condition=Ready pod/lifecycle-hooks-demo --timeout=120s
```

**Expected:**

Wait succeeds.

---

## Step 3 — Verify postStart ran

**What happens when you run this:**

`kubectl exec` reads `/tmp/postStart-ran` in the **`app`** container. `2>/dev/null || true` prevents a non-zero exit if the file were missing on a slow start — explain once per lesson that we tolerate that for script-style runs.

**Say:**

If this file is missing, postStart may not have completed yet or the hook failed; I would check Events and hook failure messages. The demo uses **exec** hooks; **httpGet** would require a listening port and path inside the container.

**Run:**

```bash
kubectl exec pod/lifecycle-hooks-demo -c app -- cat /tmp/postStart-ran 2>/dev/null || true
```

**Expected:**

Non-empty content such as `postStart` from the hook’s `echo`.

---

## Step 4 — Inspect conditions and events before testing preStop

**What happens when you run this:**

`describe` slice shows Conditions and Events — read-only. Use a **second terminal** with `kubectl delete pod lifecycle-hooks-demo --wait=false` and watch logs or events to see **preStop** during termination.

**Say:**

preStop is the graceful **drain** hook: I narrate deletes on camera in two terminals so viewers see the five-second sleep before SIGTERM proceeds.

**Run:**

```bash
kubectl get pod lifecycle-hooks-demo -o wide
kubectl describe pod lifecycle-hooks-demo | sed -n '/Conditions:/,/Events:/p'
```

**Expected:**

Pod Running; Conditions and Events visible.

---

## Troubleshooting

- **`postStart` hook failed** → check Events; fix command path or permissions; remember postStart is **async** — do not use it for strict ordering with the main process
- **`preStop` never seems to run** → ensure you are deleting the pod (hook runs on termination); very short **terminationGracePeriodSeconds** can cut hook time
- **httpGet hook fails** → wrong port/path, or main process not listening yet; align with readiness of the app
- **Container killed before graceful work finishes** → increase **terminationGracePeriodSeconds** or shorten hook work; SIGKILL still happens after grace expires
- **`exec` hook and minimal images** → image must contain the shell or binary you invoke
- **Hook failure blocks termination** → failed preStop consumes grace period; diagnose from `kubectl describe pod` during delete

---

## Learning objective

- Contrasted **postStart** and **preStop** and tied **preStop** to time before **SIGTERM** within **terminationGracePeriodSeconds**.
- Compared **exec** and **httpGet** hooks and described hook **failure** effects during lifecycle.
- Verified **postStart** side effects with `kubectl exec`.

## Why this matters

Rolling updates and scale-downs send SIGTERM; without preStop, load balancers may still send traffic while the process is exiting. Hooks are how you align Kubernetes signals with real connection draining.

## Video close — fast validation

**What happens when you run this:**

Wide pod and Conditions/Events slice — read-only; use a follow-up delete in another shell if demonstrating preStop live.

**Say:**

I use this snapshot right before I demo delete in a second terminal so the audience sees steady state first.

**Run:**

```bash
kubectl get pod lifecycle-hooks-demo -o wide
kubectl describe pod lifecycle-hooks-demo | sed -n '/Conditions:/,/Events:/p'
```

**Expected:**

Running pod; useful event lines for teaching.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/lifecycle-hooks-demo.yaml` | postStart / preStop demo |
| `yamls/failure-troubleshooting.yaml` | Hook failures / grace period |

---

## Cleanup

**What happens when you run this:**

Deletes the demo pod; `--ignore-not-found` and `|| true` make cleanup safe to repeat.

**Say:**

After filming preStop, I delete the pod; `|| true` keeps a second cleanup from erroring.

**Run:**

```bash
kubectl delete pod lifecycle-hooks-demo --ignore-not-found 2>/dev/null || true
```

**Expected:**

Pod removed or already gone.

---

## Next

[2.3.5 Container Runtime Interface (CRI)](../2.3.5-container-runtime-interface-cri/README.md)
