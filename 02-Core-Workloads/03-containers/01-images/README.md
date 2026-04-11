# 2.3.1 Images — teaching transcript

## Intro

The `image:` field is not just a string — it is a contract with the node. **imagePullPolicy** tells kubelet when to contact the registry: **Always** pulls every time a pod starts (common with `:latest` or when you must see fresh layers), **IfNotPresent** uses a cached image when one exists on the node, **Never** never pulls and only runs what is already local (breaks if the image is missing). Tags move; **digests** (`image@sha256:...`) pin exact content. Private registries need a **dockerconfigjson** Secret referenced from **imagePullSecrets** on the Pod or ServiceAccount. Nodes also run **image garbage collection** to reclaim disk, which can evict unused layers and interact with **IfNotPresent** in ways that surprise people who assume “cached forever.”

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md); cluster that can pull `nginx:1.27`.

**Teaching tip:** Demo Pod lives in **`default`** as `image-pull-demo`.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/02-Core-Workloads/03-containers/01-images"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  apply Pod (IfNotPresent + tag)  →  wait Ready  →  read image + policy from API
                                                          │
                                                          ▼
                                              events / describe (pull path)
```

**Say:**

We apply a pod that pins `IfNotPresent` and a versioned tag, wait until the kubelet has started it, then read back the live spec and the event trail so pulls are visible.

---

## Step 1 — Apply the demo Pod

**What happens when you run this:**

`kubectl apply -f yamls/image-pull-demo.yaml` creates Pod `image-pull-demo` in `default` with `image: nginx:1.27` and `imagePullPolicy: IfNotPresent`. If the object already exists, apply updates only changed fields.

**Say:**

`IfNotPresent` means: if `nginx:1.27` is already on the node, kubelet skips the registry round-trip; otherwise it pulls once, then caches.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/02-Core-Workloads/03-containers/01-images"
kubectl apply -f yamls/image-pull-demo.yaml
```

**Expected:**

`pod/image-pull-demo created` or `configured` / `unchanged`.

---

## Step 2 — Wait until the Pod is Ready

**What happens when you run this:**

`kubectl wait` blocks until the Pod’s Ready condition is true or the timeout elapses — read-only except for client wait state.

**Say:**

I wait before inspecting so I am not reading a pod that is still pulling or scheduling.

**Run:**

```bash
kubectl wait --for=condition=Ready pod/image-pull-demo -n default --timeout=120s
```

**Expected:**

`condition met` or equivalent success message.

---

## Step 3 — Read image and pull policy from the live object

**What happens when you run this:**

`jsonpath` prints the first container’s `image` and `imagePullPolicy` from the API — read-only.

**Say:**

This confirms what the API actually stored. **Always** would force a pull on every restart; **Never** would error if the image were absent locally. Our manifest uses **IfNotPresent** plus a tag — for production immutability many teams switch the image field to a **digest** so the content cannot change under the same reference.

**Run:**

```bash
kubectl get pod image-pull-demo -n default -o jsonpath='{.spec.containers[0].image}{"\n"}{.spec.containers[0].imagePullPolicy}{"\n"}'
```

**Expected:**

First line `nginx:1.27`; second line `IfNotPresent`.

---

## Step 4 — Inspect scheduling and pull events

**What happens when you run this:**

`kubectl get ... -o wide` shows node and IP; `describe` prints Events including `Pulling` / `Pulled` when a pull occurred — read-only.

**Say:**

With **IfNotPresent**, a second pod using the same image on the same node may show no pull lines if the layer is already present. **imagePullSecrets** would appear in the spec when pulling from a private registry; without them you see `ImagePullBackOff` and `401`/`403`-style hints in events.

**Run:**

```bash
kubectl get pod image-pull-demo -n default -o wide
kubectl describe pod image-pull-demo -n default | sed -n '/Events:/,$p'
```

**Expected:**

Pod row with `NODE` set; Events section shows pull or “already present” style messages depending on cache state.

---

## Troubleshooting

- **`ImagePullBackOff` or `ErrImagePull`** → check image name, registry reachability, and **imagePullSecrets** for private repos; `kubectl describe pod` for the exact message
- **`InvalidImageName`** → fix tag or digest syntax; digests use `repo/image@sha256:...`
- **Pod uses `:latest` but you see stale behavior** → combine **imagePullPolicy: Always** or pin by **digest**; tags are not immutable
- **Node disk pressure / unexpected re-pulls** → **image garbage collection** evicts unused images; `IfNotPresent` may pull again after GC removes layers
- **`imagePullPolicy` omitted** → defaults are **Always** for `:latest` and **IfNotPresent** otherwise — verify with `kubectl get pod -o yaml`
- **`Never` and pod stays `ErrImagePull` or `ImagePullBackOff`** → image must exist on the node already; pull with another policy or preload on the node

---

## Learning objective

- Contrasted **Always**, **IfNotPresent**, and **Never** and related them to cache and registry traffic.
- Explained **digest** pinning versus mutable **tags** and when each fits.
- Named **imagePullSecrets** for private registries and **image GC** as factors that change pull behavior on nodes.

## Why this matters

Most “it worked yesterday” image stories are policy plus cache plus registry auth. Teaching the fields explicitly prevents hours of blind `kubectl delete pod` loops.

## Video close — fast validation

**What happens when you run this:**

Wide status and the Events tail for the demo pod — read-only.

**Say:**

I end with the same two lines I use after any image change: wide row, then events for pull and start.

**Run:**

```bash
kubectl get pod image-pull-demo -n default -o wide
kubectl describe pod image-pull-demo -n default | sed -n '/Events:/,$p'
```

**Expected:**

Running pod with node; Events show recent lifecycle lines.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/image-pull-demo.yaml` | Pod + pull policy |
| `yamls/failure-troubleshooting.yaml` | ImagePullBackOff / auth |

---

## Cleanup

**What happens when you run this:**

Deletes the demo pod. `--ignore-not-found` and `|| true` keep re-runs and second takes from failing.

**Say:**

I clean up the lab pod; the trailing `|| true` means a missing object does not break my script.

**Run:**

```bash
kubectl delete pod image-pull-demo -n default --ignore-not-found 2>/dev/null || true
```

**Expected:**

Pod removed or delete ignored cleanly.

---

## Next

[2.3.2 Container environment](../2.3.2-container-environment/README.md)
