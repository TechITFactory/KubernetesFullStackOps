# 1.1 Learning Environment

## Overview

Before you run `kubectl` against real work, you need a **cluster on your machine** — no cloud account required for this module.

You will **either** use **Minikube (1.1.1)** **or** **Kind (1.1.2)** — pick one and stay on it. Then **1.1.3** adds a governed workspace namespace (`dev-local`) on top of whichever cluster you chose.

Lessons **1.1.1–1.1.3** use the same format as Part 0: **teaching transcript** with **Say → Run → Expected** in numbered steps.

## Sections

| Lesson | Link | Choose if… |
|--------|------|------------|
| **1.1.1** | [Minikube setup](1.1.1-minikube-setup-and-configuration/README.md) | You want one node, addons (e.g. Ingress), familiar “minikube service” flow. |
| **1.1.2** | [Kind](1.1.2-kind-kubernetes-in-docker/README.md) | You want multi-node-in-Docker, fast spin-up, CI-like workflows. |
| **1.1.3** | [Local dev clusters / dev-local](1.1.3-local-development-clusters/README.md) | **After** 1.1.1 or 1.1.2 — quotas, limit ranges, demo app in `dev-local`. |

## Module wrap — quick validation

After **1.1.3**, with your usual context (add `--context kind-kfsops-kind` if you use Kind):

```bash
kubectl cluster-info
kubectl get ns dev-local
kubectl get quota,limitrange -n dev-local
kubectl get pods -n dev-local -o wide
```
