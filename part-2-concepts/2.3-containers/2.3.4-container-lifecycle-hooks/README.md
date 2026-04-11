# 2.3.4 Container Lifecycle Hooks — teaching transcript

## Intro

**postStart** and **preStop** run in the container namespace; they interact with **termination grace** (`terminationGracePeriodSeconds`) and signal delivery.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md); cluster can pull `busybox:1.36`.

**Teaching tip:** `postStart` runs asynchronously with the main process — do not rely on strict ordering for correctness.

## Lab — Quick Start

**What happens when you run this:**  
- Apply Pod with `postStart` (writes `/tmp/postStart-ran`) and `preStop` (sleep).  
- Wait Ready.  
- `exec cat` proves postStart ran (file inside **`app`** container).

```bash
kubectl apply -f yamls/lifecycle-hooks-demo.yaml
kubectl wait --for=condition=Ready pod/lifecycle-hooks-demo --timeout=120s
kubectl exec pod/lifecycle-hooks-demo -c app -- cat /tmp/postStart-ran 2>/dev/null || true
```

**Expected:**  
File contains `postStart` marker (or non-empty line from the hook’s `echo`).

## Video close — fast validation

**What happens when you run this:**  
Wide pod; Conditions / events slice — useful before testing **delete** to watch preStop in another terminal.

```bash
kubectl get pod lifecycle-hooks-demo -o wide
kubectl describe pod lifecycle-hooks-demo | sed -n '/Conditions:/,/Events:/p'
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/lifecycle-hooks-demo.yaml` | postStart / preStop demo |
| `yamls/failure-troubleshooting.yaml` | Hook failures / grace period |

## Cleanup

```bash
kubectl delete pod lifecycle-hooks-demo --ignore-not-found
```

## Next

[2.3.5 Container Runtime Interface (CRI)](../2.3.5-container-runtime-interface-cri/README.md)
