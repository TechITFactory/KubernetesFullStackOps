# 3.2.39 Upgrade A Cluster

- Summary: Upgrade Kubernetes cluster components safely with prechecks and rollback awareness.
- Content:
  - Upgrade control plane first, then worker nodes.
  - Validate compatibility, backups, and health at each step.
  - Use drain/uncordon workflow for node upgrades.
- Lab:

```bash
kubectl get nodes
kubectl version
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply <target-version>
kubectl get pods -n kube-system
```

Worker node flow:

```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
# upgrade kubelet/kubectl packages on node
kubectl uncordon <node-name>
kubectl get nodes
```

Success signal: all nodes Ready and system pods stable after upgrade.
Failure signal: control-plane components fail to start or nodes stay NotReady.
