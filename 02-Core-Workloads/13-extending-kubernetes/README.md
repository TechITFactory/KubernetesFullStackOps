# Extending Kubernetes — teaching transcript

## Intro

**Kubernetes** **is** **designed** **to** **be** **extended**: **CNI** **plugins** **implement** **Pod** **networking**, **CSI** **drivers** **implement** **storage**, **device** **plugins** **advertise** **hardware**, **CustomResourceDefinitions** **add** **new** **API** **types**, **aggregation** **serves** **extension** **API** **servers**, **and** **operators** **encode** **domain** **automation** **in** **controllers**. **This** **module** **walks** **those** **layers** **with** **`kubectl`-visible** **surfaces** **and** **repo** **inspect** **scripts** **where** **they** **exist**.

**Prerequisites:** [2.11 Cluster administration](../11-cluster-administration/README.md) **(addons**, **webhooks**, **CRDs)**; [2.12 Windows in Kubernetes](../12-windows-in-kubernetes/README.md) **(optional**, **OS-specific** **extensions)**.

## Flow of this lesson

```
  2.13.1 Infrastructure extensions (CNI, device plugins)
              │
              ▼
  2.13.2 API extensions (CRDs, aggregation)
              │
              ▼
  2.13.3 Operator pattern (controllers + CRDs + lifecycle)
```

**Say:**

**I** **tell** **students** **to** **mentally** **sort** **every** **new** **YAML** **into** **“ships** **with** **kube”** **vs** **“comes** **from** **a** **plugin** **or** **operator”**—**that** **one** **habit** **prevents** **magic** **thinking**.

## Learning objective

- Navigate **the** **seven** **lesson** **folders** **below** **in** **order** **(parents** **then** **children)**.
- Use **`kubectl api-resources`** **and** **grep** **patterns** **from** **inspect** **scripts** **to** **see** **extensions** **in** **a** **live** **cluster**.

## Why this matters

**Every** **production** **cluster** **is** **Kubernetes** **plus** **dozens** **of** **extensions**—**understanding** **the** **hooks** **is** **how** **you** **own** **the** **platform**.

## Children (suggested order)

1. [2.13.1 Compute, storage, and networking extensions](01-compute-storage-and-networking-extensions/README.md) **(overview)**
2. [2.13.1.1 Network plugins](02-network-plugins/README.md)
3. [2.13.1.2 Device plugins](03-device-plugins/README.md)
4. [2.13.2 Extending the Kubernetes API](04-extending-the-kubernetes-api/README.md) **(overview)**
5. [2.13.2.1 Custom resources](05-custom-resources/README.md)
6. [2.13.2.2 Kubernetes API aggregation layer](06-kubernetes-api-aggregation-layer/README.md)
7. [2.13.3 Operator pattern](07-operator-pattern/README.md)

## Module wrap — quick validation

**What happens when you run this:** **CRD** **count** **and** **sample** **aggregated** **APIService** **rows**.

**Say:**

**Before** **2.13.2.1**, **I** **run** **`kubectl api-resources | wc -l`** **twice** **across** **Kubernetes** **minor** **upgrades** **to** **show** **how** **fast** **the** **API** **surface** **grows**.

```bash
kubectl get crd --no-headers 2>/dev/null | wc -l 2>/dev/null || true
kubectl get apiservice 2>/dev/null | grep -v Local | head -n 15 || true
```

## Troubleshooting

- **Empty** **CRD** **list** **with** **RBAC** **errors** → **use** **read-only** **elevated** **context** **or** **slides**
- **Confusion** **between** **CRD** **and** **operator** → **CRD** **defines** **schema**; **operator** **reconciles** **instances**
- **Wrong** **cluster** → **`kubectl config current-context`**

## Next

[Part 2: Concepts — module list](../README.md)
