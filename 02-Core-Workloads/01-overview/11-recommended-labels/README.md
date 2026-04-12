# Recommended Labels — teaching transcript

## Intro

Kubernetes has a standard label vocabulary — the `app.kubernetes.io/*` prefix — and using it consistently changes how every tool that touches your cluster behaves.

Helm uses these labels. `kubectl` uses them. Dashboards like Kubernetes Dashboard and Grafana use them to group resources by application, version, and component. Cost allocation tools use `app.kubernetes.io/part-of` to aggregate spend. If you're using the standard labels, tooling works out of the box. If you're inventing your own label schema, you're configuring every tool separately.

The labels are not enforced by Kubernetes — nothing breaks if you don't use them. But teams that adopt them from day one consistently report that onboarding, debugging, and tool integration are faster.

**Prerequisites:** [Part 1](../../01-Local-First-Operations/README.md).

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/02-Core-Workloads/01-overview/11-recommended-labels"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

---

## The recommended label set

| Label | Purpose | Example |
|-------|---------|---------|
| `app.kubernetes.io/name` | Name of the application | `nginx`, `postgres` |
| `app.kubernetes.io/instance` | Unique instance name | `my-release`, `prod-db-1` |
| `app.kubernetes.io/version` | Current version | `1.14.2`, `5.7.21` |
| `app.kubernetes.io/component` | Component role | `frontend`, `database`, `cache` |
| `app.kubernetes.io/part-of` | Larger application this belongs to | `wordpress`, `payment-service` |
| `app.kubernetes.io/managed-by` | Tool managing this | `helm`, `kustomize`, `argocd` |

---

## Flow of this lesson

```
  [ Step 1 ]             [ Step 2 ]            [ Step 3 ]
  Apply labeled   →      Wait for      →       Query by
  Deployment             rollout               standard labels
```

**Say:**

Three steps. Apply a Deployment with recommended labels, wait for rollout, then query it using the standard label keys to confirm filtering works.

---

## Step 1 — Apply the labeled Deployment

**What happens when you run this:**
`kubectl apply -f yamls/recommended-labels-demo.yaml` creates a Deployment with all six `app.kubernetes.io/*` labels set on both the Deployment itself and its pod template. Declarative; safe to re-run.

**Say:**
Notice the labels are on two places in the manifest: `metadata.labels` on the Deployment, and `spec.template.metadata.labels` on the pod template. The pod template labels are what the selector matches. The Deployment labels are what tools use to find the Deployment itself. Both matter.

**Run:**

```bash
cd "$COURSE_DIR/02-Core-Workloads/01-overview/11-recommended-labels"
kubectl apply -f yamls/recommended-labels-demo.yaml
```

**Expected:**
`deployment.apps/labels-demo created` or unchanged.

---

## Step 2 — Wait for rollout

**What happens when you run this:**
`kubectl wait --for=condition=available deployment/labels-demo --timeout=120s` waits until the Deployment is Available. Read-only.

**Say:**
Waiting for available before querying gives me a clean state — pods are running and ready, not just scheduled.

**Run:**

```bash
kubectl wait --for=condition=available deployment/labels-demo --timeout=120s
```

**Expected:**
`deployment.apps/labels-demo condition met`.

---

## Step 3 — Query using recommended labels

**What happens when you run this:**
`kubectl get deploy labels-demo --show-labels` shows all labels on the Deployment. The `kubectl get -l 'app.kubernetes.io/part-of=overview-module'` query demonstrates cross-resource filtering using the standard label. Both read-only.

**Say:**
This is the payoff. I can query by `part-of` and get every resource in this module that uses the standard label — Deployments, Services, ConfigMaps, whatever. I don't need to know the exact name of each resource. In a large cluster with hundreds of objects, this is how you find everything belonging to a specific application in one command.

**Run:**

```bash
kubectl get deploy labels-demo -n default --show-labels
kubectl get deploy -n default -l 'app.kubernetes.io/part-of=overview-module'
```

**Expected:**
First command: `labels-demo` with all labels shown. Second command: same Deployment returned by the `part-of` selector.

---

## Troubleshooting

- **Query returns nothing** → check the label value matches exactly; `app.kubernetes.io/part-of` values are case-sensitive; use `kubectl get deploy labels-demo --show-labels` to see what's actually on the object
- **Helm overwrites my labels** → Helm sets its own `app.kubernetes.io/managed-by: Helm` label and may manage the selector; if you're using Helm, let it manage labels and annotate additional metadata separately
- **Label drift between Deployment and pod template** → the Deployment's `spec.selector` must match pod template labels and cannot be changed; ensure the recommended labels on the pod template include the same key-value pairs as the selector

---

## Learning objective

- Name the six `app.kubernetes.io/*` recommended labels and their purpose.
- Apply a Deployment with all recommended labels and query it using `part-of`.
- Explain why using the recommended labels improves tool integration.

## Why this matters

Teams that use ad-hoc label schemas spend time configuring every monitoring dashboard, every cost tool, every GitOps controller separately. Teams that use the `app.kubernetes.io/*` vocabulary get most of that for free — tools are built to understand these labels out of the box. It's a small discipline that pays returns across every operational tool you'll ever use.

---

## Video close — fast validation

**What happens when you run this:**
jsonpath label dump showing all `app.kubernetes.io` labels on the Deployment, then cleanup.

**Say:**
The jsonpath iterates over every label key-value pair and prints them. I'm grepping for `app.kubernetes.io` to show just the standard labels. Then I clean up with `delete -f`.

```bash
kubectl get deploy labels-demo -n default \
  -o jsonpath='{range $k,$v := .metadata.labels}{$k}={$v}{"\n"}{end}' \
  | grep app.kubernetes.io
kubectl delete -f yamls/recommended-labels-demo.yaml --ignore-not-found
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/recommended-labels-demo.yaml` | Deployment with all six recommended labels |
| `yamls/failure-troubleshooting.yaml` | Label drift and selector mismatch hints |

---

## Next

[2.1.2.10 Storage versions](../12-storage-versions/README.md)
