# 2.1.3 The Kubernetes API — teaching transcript

## Intro

Everything in Kubernetes goes through the API server. `kubectl apply`, `kubectl get`, controller reconcile loops, kubelet heartbeats — all of it is HTTP calls to the same API.

Understanding the API directly — not just through `kubectl` — means you can debug situations where `kubectl` doesn't show what you need, build tooling that talks to the cluster, understand what admission controllers see, and explain why some operations are fast and others slow.

This lesson uses **discovery** — the API's built-in mechanism for advertising what it serves. The endpoints `/api` and `/apis` list every group, version, and resource available. `kubectl api-resources` and `kubectl api-versions` are wrappers around these same endpoints. Knowing how to call them directly means you understand what's behind those commands.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** Script behavior is documented in the header of `scripts/explore-k8s-api.sh`.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/02-Core-Workloads/01-overview/13-the-kubernetes-api"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]              [ Step 2 ]
  Run explore     →       Hit raw API
  script                  discovery endpoints
```

**Say:**

Two steps — run the API exploration script to see discovery in action, then manually hit the raw discovery endpoints to see the JSON underneath.

---

## API map (core vs named groups)

```
  /api/v1  ────── core group (Pods, Services, ConfigMaps, Namespaces, ...)
      │
      └── namespaced resources live under
          /api/v1/namespaces/<ns>/<resource>

  /apis  ──────── every other APIGroup (apps/v1, batch/v1, networking.k8s.io/v1, ...)
      │
      └── example:
          /apis/apps/v1/namespaces/<ns>/deployments
```

**Say:**

`/api` is the legacy **core** group (`apiVersion: v1`). `/apis` lists **named** groups such as **apps**, **batch**, and **networking.k8s.io**. Discovery tells `kubectl` which URL to call for each kind.

### kubectl → HTTP (examples)

| Intent | Approximate request |
|--------|---------------------|
| `kubectl get pods -n default` | `GET /api/v1/namespaces/default/pods` |
| `kubectl get deploy -n default` | `GET /apis/apps/v1/namespaces/default/deployments` |
| `kubectl get svc -n default` | `GET /api/v1/namespaces/default/services` |
| `kubectl get ns` | `GET /api/v1/namespaces` |
| `kubectl get ingressclass` | `GET /apis/networking.k8s.io/v1/ingressclasses` (cluster-scoped) |
| `kubectl apply -f deploy.yaml` (existing name) | `PATCH /apis/apps/v1/namespaces/<ns>/deployments/<name>` (server-side apply semantics) |

---

## Step 1 — Run the API exploration script

**What happens when you run this:**
`chmod +x scripts/*.sh` makes the script executable. `explore-k8s-api.sh` runs `kubectl api-versions`, `kubectl api-resources`, and `kubectl get --raw /` — the API root discovery document. All read-only.

**Say:**
`kubectl api-resources` is the most useful output here. It shows every resource the cluster serves — the kind name, whether it's namespaced, and what verbs (get, list, watch, create, update, patch, delete) apply to it. This is the source of truth for what you can do with `kubectl`.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/02-Core-Workloads/01-overview/13-the-kubernetes-api"
chmod +x scripts/*.sh
./scripts/explore-k8s-api.sh
```

**Expected:**
`api-versions` list; `api-resources` table; root discovery JSON printed (may be long).

---

## Step 2 — Read the raw discovery endpoints

**What happens when you run this:**
`kubectl get --raw /api` hits the core API group discovery endpoint and returns JSON listing API versions. `kubectl get --raw /apis` hits the named groups endpoint — everything outside the core group (apps, batch, networking.k8s.io, etc.). Both are read-only. `head -c 300` truncates so the terminal doesn't flood.

**Say:**
`/api` is the core group — it contains Pods, Services, ConfigMaps, Namespaces, Nodes. Everything with `apiVersion: v1`. `/apis` is every other group — apps, batch, networking, storage, rbac. When `kubectl` talks to the cluster, it hits these discovery endpoints first to know which URL to use for a given resource kind.

**Run:**

```bash
kubectl get --raw /api | head -c 300 && echo
kubectl get --raw /apis | head -c 300 && echo
```

**Expected:**
JSON discovery payloads — `apiVersion`, `kind: APIVersions` for `/api`, and `kind: APIGroupList` for `/apis`.

---

## Troubleshooting

- **`Forbidden` on `--raw` endpoints** → your kubeconfig doesn't have permission to read discovery; on most clusters, authenticated users have this by default; check your RBAC bindings
- **`kubectl api-resources` returns no output for a group** → the CRD or API group is not installed; check `kubectl get crds` for custom resources
- **API call returns 404** → either the resource doesn't exist, the namespace is wrong, or you're using the wrong API path; check `kubectl api-resources --verbs=get -o wide | grep <resource>`
- **Discovery slow on large clusters** → the API server caches discovery; a slow first call is normal; subsequent calls use the cache

---

## Learning objective

- Explained API discovery and how `kubectl` caches group/version metadata.
- Called `/api` and `/apis` with `kubectl get --raw` and read the JSON payloads.
- Mapped everyday `kubectl` commands to their HTTP paths using the table in this lesson.

## Why this matters

When you write a Kubernetes operator, a CI/CD integration, or even just a complex `curl` against the API, you need to know this structure. When `kubectl` returns confusing errors, knowing the API path helps you debug whether the error is from the client or the server. The API is Kubernetes — everything else is a layer on top of it.

---

## Video close — fast validation

**What happens when you run this:**
Control-plane endpoint; sampled resource types and API versions — read-only recap.

**Say:**
`kubectl cluster-info` shows the API server URL — that's what every `kubectl` call hits. `api-resources` and `api-versions` show the surface. These three commands give me a complete picture of the cluster's API in 10 seconds.

```bash
kubectl cluster-info
kubectl api-resources | head -n 25
kubectl api-versions | head -n 20
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/explore-k8s-api.sh` | Discovery bundle — api-versions, api-resources, root raw |
| `yamls/api-discovery-notes.yaml` | Reference ConfigMap with API structure notes |
| `yamls/failure-troubleshooting.yaml` | Auth and discovery failure hints |

---

## Next

[2.1.4 The kubectl command-line tool](../2.1.4-the-kubectl-command-line-tool/README.md)
