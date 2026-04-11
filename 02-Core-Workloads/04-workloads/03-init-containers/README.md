# 2.4.1.2 Init Containers â€” teaching transcript

## Intro

**Init containers** run **to completion**, in **order**, before any **app containers** start. Kubernetes guarantees that **init N** finishes successfully before **init N+1** starts, and all inits finish before the main containers run. If an init container **fails**, the kubelet restarts the Pod according to **`restartPolicy`**â€”with **`Always`**, you see retry loops until success or backoff limits; the whole Pod is restarted in that sense, not â€œjust the init.â€ Typical uses: **wait for a dependency** (database TCP check), **seed a volume** (download or `chown`), or **run a one-shot migration** before the app binary starts. Inspecting **`status.initContainerStatuses`** shows per-init state separate from app containers.

**Prerequisites:** [2.4.1.1 Pod Lifecycle](../02-pod-lifecycle/README.md) recommended.

## Flow of this lesson

```
  Pod created
      â”‚
      â–¼
  Init 0 â†’ completes
      â”‚
      â–¼
  Init 1 â†’ completes  (if defined)
      â”‚
      â–¼
  App containers start
```

**Say:**

If any init fails, the app never startsâ€”that is the point. Use inits for **gating**, not for long-running daemons.

## Learning objective

- Explain **sequential ordering** of init containers versus **parallel** app containers.
- Relate init **failure** to Pod **restartPolicy** behavior.
- Read **`initContainerStatuses`** with `kubectl` and **jsonpath**.

## Why this matters

Bad init scripts are a top cause of â€œapp never becomes Readyâ€ with **no app logs**â€”because the app container never starts.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.4-workloads/01-pods/03-init-containers" 2>/dev/null || cd .
```

## Step 1 â€” Apply the demo and wait for Ready

**What happens when you run this:**

The Podâ€™s init containers execute in order; when they succeed, the main container stays up. Logs show ordering when you use `--all-containers`.

**Say:**

I tell the audience to watch **Init Containers** in `describe` if Ready is slow.

**Run:**

```bash
kubectl apply -f yamls/init-containers-demo.yaml
kubectl wait --for=condition=Ready pod/init-containers-demo --timeout=120s
kubectl logs pod/init-containers-demo --all-containers=true --tail=30
```

**Expected:** Init container(s) complete before the main container stays `Running`; log order reflects startup sequence.

---

## Step 2 â€” Inspect init statuses with jsonpath

**What happens when you run this:**

`jsonpath` prints compact **initContainerStatuses** stateâ€”faster than scrolling YAML in a demo.

**Say:**

In incidents I compare **waiting.reason** here against **Events** at the bottom of `describe`.

**Run:**

```bash
kubectl get pod init-containers-demo -o jsonpath='{range .status.initContainerStatuses[*]}{.name}{"\t"}{.state}{"\n"}{end}'
kubectl describe pod init-containers-demo | sed -n '/Init Containers:/,/Containers:/p'
```

**Expected:** One line per init with `terminated` or empty running state after success; `describe` slice lists init specs.

## Video close â€” fast validation

**Say:**

Closing shot ties **jsonpath** back to the teaching objective.

```bash
kubectl get pod init-containers-demo -o jsonpath='{.status.initContainerStatuses[*].state}'
echo
kubectl get pod init-containers-demo -o wide
```

## Troubleshooting

- **Pod stuck `Init:`** â†’ `kubectl describe` init section; check image pull and command exit codes
- **Init succeeds but app `CrashLoopBackOff`** â†’ separate from init; debug app container logs
- **Restart loop on init** â†’ fix failing command; reduce flakiness of external dependency checks
- **Wrong image for init** â†’ init often uses different image than app; verify `image:` per container
- **No logs from app** â†’ inits still running or failed; check **initContainerStatuses**
- **`Forbidden` applying** â†’ RBAC or policy blocking Pod create

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/init-containers-demo.yaml` | Ordered init + app containers |
| `yamls/failure-troubleshooting.yaml` | Ordering, image pull, retry drills |

## Cleanup

```bash
kubectl delete -f yamls/init-containers-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.1.3 Sidecar Containers](../04-sidecar-containers/README.md)
