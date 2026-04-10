# 2.4.1.7 Pod Quality of Service Classes

- Summary: QoS classes influence eviction behavior and come directly from how requests and limits are defined.
- Content: Compare Guaranteed, Burstable, and BestEffort.
- Lab: Apply the QoS examples and inspect resulting classes.

## Assets

- `yamls/pod-qos-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/pod-qos-demo.yaml
kubectl wait --for=condition=Ready pod/qos-guaranteed --timeout=120s
kubectl wait --for=condition=Ready pod/qos-besteffort --timeout=120s
kubectl get pod qos-guaranteed qos-besteffort -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
```

## Expected output

- Both QoS demo pods are `Running` with distinct `status.qosClass` values.

## Video close - fast validation

```bash
kubectl get pod qos-guaranteed qos-besteffort -o wide
kubectl describe pod qos-guaranteed | sed -n '/QoS Class:/p'
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common resource requests/limits mistakes and QoS misclassification.
