# 2.1.2.6 Field Selectors — teaching transcript

## Intro

Label selectors filter by what you put on objects. Field selectors filter by what the API server knows about objects.

The difference matters when you need to query on state. `status.phase=Running` is a field — not a label. You can't add it to `metadata.labels`. But you can filter on it directly with `--field-selector=status.phase=Running`. Same for node name, namespace name, or any other field the API server indexes.

Field selectors are less powerful than label selectors — they support only equality (`=`, `==`, `!=`) on a limited set of indexed fields, and which fields are supported varies by resource type. But for the fields they do support, they're the only way to filter at the API level rather than piping through `grep`.

**Prerequisites:** [Part 1](../../../../part-1-getting-started/README.md).

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/02-Core-Workloads/01-overview/08-field-selectors"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]              [ Video close ]
  Run demo script  →      Manual field-selector
  (Running + Warning)     examples
```

**Say:**

One step — run the field selector demo script, then look at two manual examples in the video close to see the syntax clearly.

---

## Step 1 — Run the field selector demo

**What happens when you run this:**
`chmod +x scripts/*.sh` makes the script executable. `field-selector-demo.sh` runs two queries: all `Running` pods cluster-wide and all `Warning` events cluster-wide. Both use `--field-selector`. Both are read-only.

**Say:**
The script shows two of the most useful field selector queries in daily operations. Running pods tells me what's actually active across the whole cluster. Warning events tells me what's unhealthy — without filtering I'd get Normal events too, which are noise.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/02-Core-Workloads/01-overview/08-field-selectors"
chmod +x scripts/*.sh
./scripts/field-selector-demo.sh
```

**Expected:**
Two lists printed. Running pods — could be long depending on your cluster. Warning events — may be empty on a healthy cluster. No `kubectl` errors.

---

## Field selector syntax

**Equality:**
```bash
# Pods in Running phase
kubectl get pods -A --field-selector=status.phase=Running

# Pods NOT in Running phase (Pending, Failed, Succeeded)
kubectl get pods -A --field-selector=status.phase!=Running

# Pods on a specific node
kubectl get pods -A --field-selector=spec.nodeName=worker-1
```

**Multiple selectors (AND only — no OR):**
```bash
kubectl get pods -A \
  --field-selector=status.phase=Running,spec.nodeName=worker-1
```

**Events by type:**
```bash
kubectl get events -A --field-selector=type=Warning
kubectl get events -A --field-selector=type=Normal
```

**Supported fields vary by resource.** If a field is not indexed by the API server, you get an error like `field label not supported: status.conditions`. Check the API docs or use `kubectl explain <resource>` for what's available.

---

## Field selectors vs label selectors — when to use which

| Use case | Tool |
|----------|------|
| Filter by state (`Running`, `Pending`) | Field selector |
| Filter by node assignment | Field selector |
| Filter by app name, version, team | Label selector |
| Filter by multiple values (OR logic) | Label selector with set-based syntax |
| Filter in Service or Deployment ownership | Label selector only |

---

## Troubleshooting

- **`field label not supported`** → that field is not indexed; use label selectors or pipe through `grep` after `kubectl get`
- **Empty results but objects exist** → confirm the field value exactly; `status.phase` values are `Running`, `Pending`, `Succeeded`, `Failed`, `Unknown` — capitalized exactly as shown
- **Field selector on custom resources** → CRDs don't have indexed fields by default; field selectors on CRs typically only support `metadata.name` and `metadata.namespace`

---

## Learning objective

- Use `--field-selector` to filter pods by phase and events by type.
- Explain the difference between field selectors and label selectors.
- Name the supported comparison operators for field selectors.

## Why this matters

`kubectl get pods -A | grep Running` works, but it filters client-side after fetching all pods. `--field-selector=status.phase=Running` filters server-side — the API returns only matching objects. On a cluster with thousands of pods, that difference is significant for both latency and readability.

---

## Video close — fast validation

**What happens when you run this:**
Head-truncated Running vs non-Running pod samples — read-only.

**Say:**
These two commands together show the full split: Running pods on the left, everything else on the right. On a healthy cluster the second list is short or empty. On a degraded cluster it tells me immediately where to look.

```bash
kubectl get pods -A --field-selector=status.phase=Running 2>/dev/null | head -n 15
kubectl get pods -A --field-selector=status.phase!=Running 2>/dev/null | head -n 15
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/field-selector-demo.sh` | Running pods + Warning events queries |
| `yamls/failure-troubleshooting.yaml` | Unsupported fields and empty result hints |

---

## Next

[2.1.2.7 Finalizers](../2.1.2.7-finalizers/README.md)
