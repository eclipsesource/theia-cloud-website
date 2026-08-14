+++
fragment = "content"
weight = 100

title = "Theia Cloud on OpenShift (experimental)"

[sidebar]
  sticky = true
+++

Since 1.3.0, Theia Cloud can be deployed on Red Hat OpenShift. Instead of Kubernetes `Ingress` resources, it uses OpenShift `Route` resources for the landing page, the REST service, and each running session. This support is **experimental**: it is exercised on OpenShift Local (CRC) and in CI on MicroShift, but is not as extensively tested as the Kubernetes and Minikube setups. Both the Theia Cloud container images and Helm charts must be version **1.3.0 or later**; follow the [general installation guide]({{< relref "setuptheiacloud" >}}) and apply the OpenShift-specific changes below.

## Prerequisites

- An OpenShift cluster; Theia Cloud is tested with [OpenShift Local (CRC)](https://developers.redhat.com/products/openshift-local/overview).
- The `oc` CLI and cluster-admin rights, which are needed to create ClusterRoles and bind the `anyuid` Security Context Constraint (SCC).
- **No Ingress controller is required.** OpenShift's built-in router serves the Routes. This is the main difference from the other setups.
- cert-manager, which is required for the CRD conversion webhook certificate. The OpenShift router's own certificate can terminate TLS for Routes, so cert-manager does not need to issue their certificates.

## Configuration

Set the cloud provider on the `theia-cloud-base` chart:

```yaml
# theia-cloud-base values
operator:
  cloudProvider: "OPENSHIFT"
```

Apply the OpenShift-specific values to the `theia-cloud` chart:

```yaml
# theia-cloud values
hosts:
  usePaths: false # required on OpenShift
  configuration:
    baseHost: apps-crc.testing
    instance: ws

operator:
  cloudProvider: "OPENSHIFT"

ingress:
  tls: true
```

`operator.cloudProvider` must be set on **both** charts. On `theia-cloud-base` it gates the `route.openshift.io` RBAC rules for the operator; without it, the operator receives `403 Forbidden` when creating session Routes.

`hosts.usePaths: true` is unsupported and rejected while rendering the chart with the message `OpenShift cloudProvider does not support hosts.usePaths: true. Set hosts.usePaths to false.`

## Session hostnames and certificates

Each session gets its own Route at `<session-uid>.<hosts.configuration.instance>.<baseHost>`. With the configuration above, the hostname is `<session-uid>.ws.<baseHost>`; for example, `<session-uid>.ws.apps-crc.testing`.

Because this is **two** labels below the apps domain, the cluster's default `*.apps-...` wildcard certificate does not match it. Provide a certificate covering `*.<hosts.configuration.instance>.<baseHost>` (for example, `*.ws.apps-crc.testing`), or expect a browser certificate warning, as happens on CRC out of the box.

## Limitations and trying it out

- Path-based hosting (`hosts.usePaths: true`) is not supported.
- `ingress.controller` and `ingress.ingressClassName` are ignored; the OpenShift router is always used. nginx and HAProxy Ingress annotations do not apply; OpenShift uses `haproxy.router.openshift.io/*` annotations. `ingress.landingPage.annotations` and `ingress.service.annotations` are applied to their respective Routes, while `ingress.instances.annotations` reach session Routes through the `openshift-route-config` ConfigMap.
- Session pods run under the `anyuid` SCC through the `theia-cloud-sessions` ServiceAccount, so cluster-admin rights are required at install time.
- For a local setup on OpenShift Local, see the [OpenShift developer/test setup](https://github.com/eclipse-theia/theia-cloud/blob/main/terraform/test-configurations/openshift.md). It is intended for development and testing, not as a supported getting-started path.
