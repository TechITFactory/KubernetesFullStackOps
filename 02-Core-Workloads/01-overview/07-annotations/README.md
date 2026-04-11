# 2.1.2.5 Annotations â€” teaching transcript

## Intro

Annotations are the other half of Kubernetes metadata â€” and they're commonly confused with labels.

The distinction is simple: **labels are for selecting, annotations are for describing**. A label is something you query on. An annotation is something you attach for tooling, documentation, or operational context. You can't use annotations in `kubectl get -l` selectors. You can't use them in Service selectors or Deployment ownership chains. But you can store anything in them â€” git commit SHAs, deploy timestamps, runbook URLs, Helm release metadata, Ingress controller directives.

Many Kubernetes features are controlled through annotations. The nginx Ingress controller reads `nginx.ingress.kubernetes.io/rewrite-target`. cert-manager reads `cert-manager.io/cluster-issuer`. Helm stores its release state in annotations. If you've ever wondered how those tools know what to do â€” annotations are how.

**Prerequisites:** [Part 1](../../part-1-getting-started/README.md).

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/02-Core-Workloads/01-overview/07-annotations"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]              [ Step 2 ]
  Apply annotated  â†’      Read annotations
  ConfigMap               two ways
```

**Say:**

Two steps â€” apply an annotated object and then read those annotations using jsonpath and describe.

---

## Step 1 â€” Apply the annotated ConfigMap

**What happens when you run this:**
`kubectl apply -f yamls/annotations-demo.yaml` creates a ConfigMap with several annotations set â€” git SHA, deploy timestamp, runbook URL, and a tool-specific hint. Declarative; safe to re-run.

**Say:**
I'll show you the manifest annotations section. Notice the key format: domain-prefixed keys like `git.example.io/commit-sha` are the recommended pattern for anything custom. Unprefixed keys work but risk colliding with Kubernetes internal annotations. Always use a domain prefix for your own annotations.

**Run:**

```bash
cd "$COURSE_DIR/02-Core-Workloads/01-overview/07-annotations"
kubectl apply -f yamls/annotations-demo.yaml
```

**Expected:**
`configmap/annotations-demo created` or unchanged.

---

## Step 2 â€” Read the annotations

**What happens when you run this:**
`kubectl get cm annotations-demo -o jsonpath='{.metadata.annotations}'` prints the annotations map as raw JSON (may be long â€” `head -c 200` truncates). `kubectl describe cm annotations-demo` shows annotations in a more readable block format. Both are read-only.

**Say:**
Two ways to read annotations. `jsonpath` is precise â€” I can extract a single annotation value with `.metadata.annotations.<key>`. `describe` is readable â€” shows all annotations with their full keys in a block. I use `jsonpath` in scripts and `describe` when I'm debugging manually.

**Run:**

```bash
kubectl get cm annotations-demo -n default -o jsonpath='{.metadata.annotations}' | head -c 200; echo
```

Then the describe view:

```bash
kubectl describe cm annotations-demo -n default | sed -n '/Annotations:/,/Data/p'
```

**Expected:**
First command: JSON map of annotation keys and values (truncated). Second command: the Annotations block from `describe`, stopping at the Data section.

---

## Common annotation patterns in production

**Traceability:**
```yaml
annotations:
  git.example.io/commit-sha: "a1b2c3d"
  deploy.example.io/timestamp: "2025-04-11T10:00:00Z"
  deploy.example.io/triggered-by: "ci-pipeline"
```

**Operational runbooks:**
```yaml
annotations:
  runbook.example.io/url: "https://wiki.example.io/runbooks/api-service"
  oncall.example.io/team: "platform"
```

**Tool configuration (Ingress controller example):**
```yaml
annotations:
  nginx.ingress.kubernetes.io/rewrite-target: /
  nginx.ingress.kubernetes.io/ssl-redirect: "true"
```

**Annotation size limit:** annotations are stored in etcd with the object. The total size of all annotations on an object must be under **256 KB**. Storing large blobs (base64-encoded binaries, very long certificates) in annotations will hit this limit. Use ConfigMaps or Secrets for large data.

---

## Troubleshooting

- **Annotation not affecting tool behavior** â†’ check the exact key spelling; annotation keys are case-sensitive and domain-prefix must match exactly what the tool expects (e.g. `nginx.ingress.kubernetes.io/`, not `ingress.nginx.io/`)
- **`kubectl get -l annotation-key=value` returns nothing** â†’ annotations cannot be used as label selectors; use labels for querying
- **`metadata.annotations` too large** â†’ annotations over 256 KB total will be rejected; move large values to ConfigMaps
- **`kubectl apply` overwrites annotation added by a tool** â†’ use `kubectl annotate` to add annotations that should persist outside your manifest, or add them to the manifest so they're tracked

---

## Learning objective

- Explain the difference between labels and annotations.
- Read annotations using `jsonpath` and `describe`.
- Name three real-world uses for annotations in production clusters.

## Why this matters

Annotations are how Kubernetes extensibility works in practice. Almost every operator, controller, and tool that integrates with Kubernetes uses annotations to receive configuration. If you don't know how to read and set annotations, you can't configure these tools â€” and you can't debug why they're not behaving as expected.

---

## Video close â€” fast validation

**What happens when you run this:**
Full describe of the annotations block, then delete the ConfigMap.

**Say:**
The `describe` output shows annotations exactly as a human would read them during an incident. This is what I look at when I'm debugging "why is this Ingress not working" â€” I check the annotations first.

```bash
kubectl describe cm annotations-demo -n default | sed -n '/Annotations:/,/Data/p'
kubectl delete cm annotations-demo -n default --ignore-not-found
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/annotations-demo.yaml` | Annotated ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Size limits and label/annotation confusion |

---

## Next

[2.1.2.6 Field selectors](../08-field-selectors/README.md)
