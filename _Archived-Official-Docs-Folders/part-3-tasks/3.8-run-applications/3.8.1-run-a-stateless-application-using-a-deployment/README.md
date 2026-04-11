# 3.8.1 Run a Stateless Application Using a Deployment

- **Summary**: Deploy an Nginx web server as a stateless application using a Kubernetes Deployment, expose it via a NodePort Service, and perform a zero-downtime rolling update from v1.27 to v1.28.
- **Content**: Stateless vs stateful, Deployment controller, ReplicaSets, rolling updates, self-healing, readiness and liveness probes.
- **Lab**: Run `deploy.sh`, observe 3 pods come up, trigger `rolling-update.sh`, watch pods cycle one at a time, run `teardown.sh` to clean up.

---

## Files

| Path | Purpose |
|------|---------|
| `yamls/00-namespace.yaml` | Isolated lab namespace `stateless-lab` |
| `yamls/01-nginx-deployment.yaml` | Nginx 1.27, 3 replicas, RollingUpdate strategy |
| `yamls/02-nginx-service.yaml` | NodePort 30080 — access the app from your host |
| `yamls/03-nginx-deployment-v2.yaml` | Nginx 1.28 — zero-downtime update target |
| `scripts/deploy.sh` | Idempotent: apply manifests, wait for healthy rollout |
| `scripts/rolling-update.sh` | Idempotent: skip if already on v2, else update and watch |
| `scripts/teardown.sh` | Idempotent: delete namespace, no-op if already gone |

## Quick Start

```bash
# 1. Deploy
./scripts/deploy.sh

# 2. Test (minikube)
curl http://$(minikube ip):30080

# 3. Rolling update to nginx:1.28
./scripts/rolling-update.sh

# 4. Clean up
./scripts/teardown.sh
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

Alright, welcome to section 3.8.1. Here is what we are building today: a web server that runs on Kubernetes, survives crashes by itself, updates without ever going down, and scales to as many copies as you need — all from a single YAML file.

By the end of this lesson you will have deployed a real Nginx server on your cluster, updated it to a new version with zero downtime, and understood exactly why Kubernetes handles it this way. Let's go.

---

### [0:45–2:30] What Is a Stateless Application?

First, let's talk about *stateless*. What does that word actually mean?

Think of a **vending machine**. You walk up, press B4, get your chips, and walk away. The machine doesn't remember you. Next person walks up — same experience. The machine holds no memory of who came before. That is stateless.

Now think of your **bank account**. Every time you log in, it knows your balance, your history, your previous transactions. It *remembers* you. That is stateful.

In software, a **stateless application** works like the vending machine:

- Every request is independent. No memory of the last one.
- Any copy of the app can handle any request — they are all identical.
- You can kill one copy, start another, and nobody notices.

A **stateful application** is like the bank. It stores data — in a database, on disk, in memory — and losing a copy means losing that data. Stateful apps need special care in Kubernetes (that is StatefulSets, which we cover in 3.8.2 and 3.8.3).

Today we focus on stateless. Our example is **Nginx** — a web server that serves static files. It has no memory of past requests. Every copy is identical. This is the easiest type of app to run on Kubernetes, and it is also the most common in real production systems.

Real-world examples of stateless apps: REST APIs, front-end web servers, microservices that read from a database but don't hold state themselves, image resizing services, authentication token validators.

---

### [2:30–4:00] What Is a Kubernetes Deployment?

Okay, so how do we run a stateless app on Kubernetes? We use a **Deployment**.

Here is the simplest way to think about it: a Deployment is a **contract** you make with Kubernetes.

You say: *"I want 3 copies of Nginx running at all times."*

Kubernetes says: *"Got it. I will make sure that is always true."*

You don't tell Kubernetes *how* to do it. You just tell it *what* you want. This is called **declarative configuration** — you declare the desired state, and Kubernetes makes it happen and keeps it that way.

Under the hood, a Deployment creates a **ReplicaSet**, which is the thing that actually creates and manages the individual pods. Think of it as:

- **You** write the Deployment — the contract.
- **ReplicaSet** is the manager who enforces the contract.
- **Pods** are the workers doing the actual job.

If a pod crashes, the ReplicaSet notices there are now only 2 running instead of 3, and it immediately starts a replacement. You don't have to do anything. This is **self-healing**.

If you want 10 copies instead of 3, you just change `replicas: 10` in your YAML. Kubernetes does the rest. This is **scaling**.

And if you want to ship a new version of your app, Kubernetes can replace pods one at a time, making sure the old ones are only removed after the new ones are healthy. This is a **rolling update**, and it means zero downtime.

---

### [4:00–5:30] The YAML — What Each Part Does

Let's look at our `01-nginx-deployment.yaml`. I want to walk through it field by field so nothing feels like magic.

```yaml
apiVersion: apps/v1
kind: Deployment
```
This tells Kubernetes: this is a Deployment resource, using the `apps/v1` API group.

```yaml
metadata:
  name: nginx-demo
  namespace: stateless-lab
```
The name of our Deployment, in an isolated namespace called `stateless-lab`. Namespaces are like folders — they keep lab resources separate from anything else on the cluster.

```yaml
spec:
  replicas: 3
```
We want 3 identical pods running at all times.

```yaml
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```
This is the update strategy. `maxUnavailable: 0` means during an update, never bring down a pod before a replacement is ready. `maxSurge: 1` means we allow one *extra* pod during the transition. So at update time we briefly have 4 pods, never fewer than 3. This is how we get zero downtime.

```yaml
  template:
    spec:
      containers:
        - name: nginx
          image: nginx:1.27
```
The actual container — Nginx version 1.27.

```yaml
          readinessProbe:
            httpGet:
              path: /
              port: 80
```
The readiness probe. Kubernetes hits `/` on port 80 before it marks this pod as ready and sends traffic to it. If the probe fails, traffic is held back. This is how we guarantee users never hit a pod that is not yet fully started.

```yaml
          livenessProbe:
```
The liveness probe. If this fails repeatedly, Kubernetes restarts the container automatically. Think of it as a heartbeat monitor.

```yaml
          resources:
            requests:
              cpu: 100m
              memory: 64Mi
            limits:
              cpu: 250m
              memory: 128Mi
```
Resource requests tell the scheduler how much CPU and memory this pod needs to find a suitable node. Limits cap the maximum it can use, protecting other workloads on the same node.

---

### [5:30–7:00] Live Demo — Deploy and Observe

Let's run the deploy script now.

```bash
./scripts/deploy.sh
```

The script does five things, and each one is **idempotent** — meaning safe to run twice:

1. `kubectl apply -f 00-namespace.yaml` — creates the namespace if it doesn't exist; if it does, nothing changes.
2. `kubectl apply -f 01-nginx-deployment.yaml` — creates the Deployment; on re-run it compares the live state to the file and only applies differences.
3. `kubectl apply -f 02-nginx-service.yaml` — creates the NodePort Service.
4. `kubectl rollout status` — blocks until all 3 pods are ready. If it times out, the script fails and you know something went wrong.
5. Prints the current state.

What you will see:

```
deployment.apps/nginx-demo created
service/nginx-demo created
Waiting for deployment "nginx-demo" rollout to finish: 0 of 3 updated replicas are available...
Waiting for deployment "nginx-demo" rollout to finish: 1 of 3 updated replicas are available...
Waiting for deployment "nginx-demo" rollout to finish: 2 of 3 updated replicas are available...
deployment "nginx-demo" successfully rolled out
```

Now test it. On minikube: `curl http://$(minikube ip):30080`. You will see the standard Nginx welcome page. The app is live.

Now kill a pod. Really — go ahead:

```bash
kubectl delete pod -n stateless-lab -l app=nginx-demo --field-selector=status.phase=Running | head -1
```

Watch what happens:

```bash
kubectl get pods -n stateless-lab -w
```

Kubernetes notices the pod count dropped to 2. In seconds it starts a new one. Your service never went down because the other 2 pods were still serving traffic the whole time. That is self-healing in action.

---

### [7:00–8:30] Rolling Update — Zero Downtime

Now let's update the app. We want to move from Nginx 1.27 to Nginx 1.28.

Run:

```bash
./scripts/rolling-update.sh
```

The script first checks what image is currently running. If it is already `nginx:1.28`, it prints "nothing to update" and exits. That is idempotency — no harm in running it again.

If we are still on `nginx:1.27`, it applies `03-nginx-deployment-v2.yaml` — which is identical to the v1 manifest except for `image: nginx:1.28`.

Then it watches:

```
Watching rolling update...
Waiting for deployment "nginx-demo" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "nginx-demo" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "nginx-demo" rollout to finish: 1 old replicas are pending termination...
deployment "nginx-demo" successfully rolled out
```

What is happening internally:

1. Kubernetes starts 1 new pod with `nginx:1.28`. (Now we have 4 total — the `maxSurge: 1`.)
2. It waits for the readiness probe on the new pod to pass.
3. Only once the new pod is ready does it terminate 1 old pod. (We never go below 3 — the `maxUnavailable: 0`.)
4. Repeat until all 3 are on `nginx:1.28`.

At no point were there fewer than 3 healthy pods serving traffic. Zero downtime.

If something goes wrong mid-update, roll back with one command:

```bash
kubectl rollout undo deployment/nginx-demo -n stateless-lab
```

Kubernetes reverts to the previous ReplicaSet. Same rolling process, in reverse.

---

### [8:30–9:30] Real World — Where This Is Used

You will see this exact pattern in almost every production Kubernetes environment:

- **E-commerce front-ends** — Deployments with 10–50 replicas serving web traffic. Rolling updates deploy new features without a maintenance window.
- **REST APIs** — Microservices behind a LoadBalancer Service. Each service is a separate Deployment, scaled independently.
- **CI/CD pipelines** — GitHub Actions or Jenkins build a new container image, tag it with the git commit SHA, update the Deployment manifest, and `kubectl apply`. Kubernetes rolls it out automatically.
- **Autoscaling** — A HorizontalPodAutoscaler (covered in 3.8.7) watches CPU usage and adjusts `replicas` on the Deployment automatically during traffic spikes.

The Deployment is the workhorse of Kubernetes. If your app doesn't need persistent storage, and most apps don't, a Deployment is how you run it.

---

### [9:30–10:00] Recap

Here is what we covered:

- **Stateless app** — no memory between requests, any copy can handle any request. Perfect fit for Kubernetes.
- **Deployment** — a declarative contract: "keep N replicas of this container running."
- **ReplicaSet** — the enforcer; restarts pods that crash.
- **Rolling update** — replace pods one at a time, new pod must be healthy before old pod is removed. Zero downtime.
- **Idempotent scripts** — `kubectl apply` is declarative; running the script twice produces the same result.
- **Probes** — readiness gates traffic in; liveness restarts hung containers.

Clean up when you're done:

```bash
./scripts/teardown.sh
```

Next up: 3.8.2 — Run a Single-Instance Stateful Application, where we introduce PersistentVolumes so data survives pod restarts.
