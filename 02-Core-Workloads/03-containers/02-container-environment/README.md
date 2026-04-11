# 2.3.2 Container Environment — teaching transcript

## Intro

The process inside the container does not only see what the Dockerfile baked in. The Pod spec adds **environment variables**: literal **`value`**, **`valueFrom.configMapKeyRef`**, **`valueFrom.secretKeyRef`**, and **downward API** via **`valueFrom.fieldRef`** so pod metadata (name, namespace, labels, annotations, resource limits) surfaces as env vars. Order matters in the sense that **later entries override earlier ones** when the same name appears twice in the `env` list. The image **ENTRYPOINT/CMD** and **`command`/`args`** in the spec still define the main process; env is injected before that process starts. DNS and mounts are separate mechanisms you will see in other lessons — here we focus on env assembly.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md); cluster can pull `busybox:1.36`.

**Teaching tip:** Manifest has no `namespace:` → Pod is created in your **current** context’s default namespace (usually `default`).

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/02-Core-Workloads/03-containers/02-container-environment"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  apply Pod (literal env + fieldRef)  →  wait Ready  →  exec printenv
                              │
                              ▼
                    describe: Environment block
```

**Say:**

We apply a pod that sets a literal training variable and pulls the pod name from the downward API, then we prove both inside the container and mirror the same story in describe output.

---

## Step 1 — Apply the environment demo Pod

**What happens when you run this:**

`kubectl apply` creates `container-environment-demo` with `TRAINING_MODULE` from a literal and `POD_NAME` from `fieldRef` on `metadata.name`. ConfigMaps and Secrets would use `configMapKeyRef` / `secretKeyRef` in the same `env` list for non-sensitive and sensitive values respectively.

**Say:**

Downward API env vars are resolved by kubelet from the live pod object. If I duplicated `POD_NAME` later in the list with another value, the **later** entry would win — that override rule is how optional layers patch configuration.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/02-Core-Workloads/03-containers/02-container-environment"
kubectl apply -f yamls/container-environment-demo.yaml
```

**Expected:**

`pod/container-environment-demo created` or unchanged.

---

## Step 2 — Wait until the Pod is Ready

**What happens when you run this:**

`kubectl wait` blocks until Ready or timeout — no API mutation.

**Say:**

`exec` needs a running container; I wait for Ready so `printenv` does not race the start sequence.

**Run:**

```bash
kubectl wait --for=condition=Ready pod/container-environment-demo --timeout=120s
```

**Expected:**

Success message from `kubectl wait`.

---

## Step 3 — Show environment inside the container

**What happens when you run this:**

`kubectl exec` runs `printenv` in the `env-demo` container; `head` truncates output for the terminal — read-only aside from running a process in the pod.

**Say:**

I expect `TRAINING_MODULE=2.3.2` from the literal and `POD_NAME` matching the object name from `fieldRef`. Kubernetes may also inject **SERVICE_** variables for Services in the same namespace as optional behavior depending on settings — those are separate from the spec `env` list.

**Run:**

```bash
kubectl exec pod/container-environment-demo -c env-demo -- printenv | head -n 30
```

**Expected:**

`TRAINING_MODULE=2.3.2`, `POD_NAME=container-environment-demo`, plus other variables as present on your cluster.

---

## Step 4 — Compare with describe output

**What happens when you run this:**

`kubectl get` wide adds scheduling columns; `describe` shows the Environment section including `POD_NAME` sourced from field — read-only.

**Say:**

Describe is what operators read during incidents; it shows the linkage from env name to ConfigMap, Secret, or field without opening the full YAML.

**Run:**

```bash
kubectl get pod container-environment-demo -o wide
kubectl describe pod container-environment-demo | sed -n '/Environment:/,/Mounts:/p'
```

**Expected:**

Wide row with node; Environment block lists `TRAINING_MODULE` and `POD_NAME` with source hints.

---

## Troubleshooting

- **`error: Internal error occurred: error executing command`** → container not ready or wrong container name; check `kubectl get pod` and `-c env-demo`
- **`CreateContainerConfigError` referencing Secret or ConfigMap** → key missing or object in wrong namespace; fix refs or create the source object
- **Downward API env empty or wrong** → verify `fieldPath` spelling (`metadata.name`, `metadata.namespace`, etc.) and that the field exists
- **Duplicate env keys** → last definition in the `env` array wins; dedupe in the manifest
- **`optional: false` on a ref and pod stuck** → required key must exist before kubelet starts the container
- **Secrets appearing in `describe`** → some versions redact values; prefer `kubectl exec` or API read with RBAC awareness for debugging

---

## Learning objective

- Injected literals and **downward API** `fieldRef` env vars and verified them with `exec` and `describe`.
- Explained how **ConfigMap** and **Secret** refs fit the same `env` list and how duplicate keys override.
- Related container env to the main process’s `command` / `args` and image defaults.

## Why this matters

Misconfigured env from Secrets or ConfigMaps is a top cause of “works on my laptop” pod crashes. Knowing fieldRef versus valueFrom keys speeds up config debugging without guessing.

## Video close — fast validation

**What happens when you run this:**

Wide pod and the Environment-to-Mounts slice from describe — read-only.

**Say:**

Closing beat: placement plus the exact env block the API server shows operators.

**Run:**

```bash
kubectl get pod container-environment-demo -o wide
kubectl describe pod container-environment-demo | sed -n '/Environment:/,/Mounts:/p'
```

**Expected:**

Running pod; Environment section visible.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/container-environment-demo.yaml` | env + fieldRef demo |
| `yamls/failure-troubleshooting.yaml` | env / downward API issues |

---

## Cleanup

**What happens when you run this:**

Deletes the demo pod; `--ignore-not-found` and `|| true` avoid errors on repeat cleanup.

**Say:**

I remove the demo workload when the segment is done.

**Run:**

```bash
kubectl delete pod container-environment-demo --ignore-not-found 2>/dev/null || true
```

**Expected:**

Pod deleted or already absent.

---

## Next

[2.3.3 Runtime class](../2.3.3-runtime-class/README.md)
