# 4.1 Hello Minikube

- Objective: Start a local cluster and deploy your first working app in minutes.
- Outcomes:
  - Install/start Minikube on Linux.
  - Deploy and access a sample app.
  - Cleanly tear down the environment.
- Notes:
  - This is local-first and job-relevant: same `kubectl` workflow used in production.

## Quick Lab (Linux)

```bash
minikube start --driver=docker --profile k8sops
kubectl create deployment hello --image=nginx:1.27
kubectl expose deployment hello --port=80 --type=NodePort
minikube service hello --url --profile k8sops
```

Validation:

```bash
kubectl get deploy,pod,svc
```

Cleanup:

```bash
kubectl delete svc hello
kubectl delete deploy hello
minikube delete --profile k8sops
```
