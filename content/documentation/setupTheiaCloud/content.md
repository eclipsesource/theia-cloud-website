+++
fragment = "content"
weight = 100

title = "Setup Theia Cloud on your Cluster"

[sidebar]
  sticky = true
+++

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

This guide explains how to install Theia Cloud on your cluster.

We recommend using Helm, the package manager for Kubernetes, for managing installations.
If you are unfamiliar with Helm, please have a look at their homepage [helm.sh](https://helm.sh/) first.

## Required Software

Theia Cloud depends on well-established software in the Kubernetes ecosystem.
We won't go into full detail explaining how to install each dependency but will provide links to their official documentation.

Please note that our [Try Theia Cloud]({{< relref "tryTheiaCloud" >}}) guides use Terraform charts that will install all requirements automatically.
Please have a look at their [Helm configuration](https://github.com/eclipse-theia/theia-cloud/blob/main/terraform/modules/helm/main.tf) to find the values used in the getting started guides.

### cert-manager.io

For certificate management, we use [cert-manager.io](https://cert-manager.io/).

We offer the installation of two cluster issuers: a self-signed issuer for testing and cluster internal usage, and an issuer for creating Let's Encrypt certificates.
You may use your existing cluster issuers as well!

We suggest installing the cert-manager using [the official Helm chart](https://cert-manager.io/docs/installation/helm/).

### Ingress Controller

Theia Cloud supports two ingress controllers: [HAProxy Ingress](https://haproxy-ingress.github.io/) (default since 1.2) and [Ingress NGINX](https://kubernetes.github.io/ingress-nginx/) (legacy; default until including 1.1). The nginx ingress controller is [being retired upstream](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/), so we recommend HAProxy for new installations.

You can configure the controller via the `ingress.controller` value in the `theia-cloud` Helm chart.

#### HAProxy

The [HAProxy Ingress Controller](https://haproxy-ingress.github.io/) is the default ingress controller for Theia Cloud.

It can be installed using the official Helm chart. The installation instructions are available in the official documentation:
[https://haproxy-ingress.github.io/docs/getting-started/#installation](https://haproxy-ingress.github.io/docs/getting-started/#installation)

Example:

```sh
helm repo add haproxy-ingress https://haproxy-ingress.github.io/charts
helm repo update
helm install haproxy-ingress haproxy-ingress/haproxy-ingress \
  --version 0.15.1 \
  --namespace ingress-haproxy \
  --create-namespace \
  --set controller.ingressClassResource.enabled=true
```

For further details, see the official HAProxy Ingress documentation:
[https://haproxy-ingress.github.io/docs/](https://haproxy-ingress.github.io/docs/)

#### nginx

The [Ingress NGINX Controller](https://kubernetes.github.io/ingress-nginx/) is still supported, but is [being retired upstream](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/). For new installations, we recommend using HAProxy.

The official deployment instructions are available here:
[https://kubernetes.github.io/ingress-nginx/deploy/](https://kubernetes.github.io/ingress-nginx/deploy/)

**Note:** Since `ingress-nginx` version 1.10, the annotation `nginx.ingress.kubernetes.io/configuration-snippet` is disabled by default and needs to be enabled. To enable this option, set the `allow-snippet-annotations: "true"` flag in the ingress-nginx values. For example, via the `ingress-nginx-controller`s config-map. For more information see the [documentation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/).

_Please note that it is possible to integrate other ingress controllers with Theia Cloud. We currently do not provide documentation for this. If you require a different ingress controller, please refer to our [available support options]({{< relref "/support" >}})._

### Keycloak (optional)

If your use case requires user management, we recommend the use of [Keycloak](https://www.keycloak.org/). Keycloak acts as an OAuth2 provider, and it is possible to integrate other existing providers into Keycloak.

We suggest using the [Bitnami Helm chart](https://github.com/bitnami/charts/tree/main/bitnami/keycloak) for the Keycloak installation.

_Please note that it is possible to integrate any OAuth2 provider with Theia Cloud, and this is part of our roadmap. We do not offer documentation and finalized APIs for this yet, however. If you need this feature sooner, please see our [available support options]({{< relref "/support" >}})._

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

## Theia Cloud Helm Charts

Theia Cloud offers three Helm charts that are available via the Helm repository hosted at <https://eclipse-theia.github.io/theia-cloud-helm/>.
These charts are designed to provide a flexible and customizable deployment of Theia Cloud on Kubernetes clusters.
The available charts are:

- `theia-cloud-base`: Installs cluster-wide resources such as issuers and roles used by Theia Cloud.
- `theia-cloud-crds`: Deploys Theia Cloud Custom Resource Definitions (CRDs) and their conversion webhook.
- `theia-cloud`: The main Helm chart, including the Operator and Service components for Theia Cloud.

To add the Theia Cloud Helm repository for access to these charts, use the following command:

```sh
helm repo add theia-cloud-repo https://eclipse-theia.github.io/theia-cloud-helm/
```

If you have previously added this repository, ensure you have the latest charts by updating the repository:

```sh
helm repo update
```

_Note:_ You might have added the repository with the old url (https://github.eclipsesource.com/theia-cloud-helm) before. If this is the case, please remove the old repo and re-add it with the new url above.

We aim to make the contents of these charts as customizable as possible.
This includes providing options to skip any optional resources during installation.
This guide provides an overview of each Helm chart along with sample configurations.
For comprehensive configuration options, refer to the linked documentation within each section.
Additionally, explore our [Terraform configurations](https://github.com/eclipse-theia/theia-cloud/tree/main/terraform/configurations) for complete Theia Cloud setups on various cluster providers, including GKE and Minikube.
For early access to customization options, new terraform examples, or if you require specific changes, please consult our [support options]({{< relref "/support" >}}).

### theia-cloud-base

This chart installs cluster-wide resources necessary for Theia Cloud's operation.
Currently, it includes two `ClusterIssuer` resources for certificate management and two `ClusterRole` resources for the Theia Cloud Operator and Service.

To install, first create a `base-values.yaml` file with your email address:

```yaml
issuer:
  email: j.doe@theia-cloud.io
```

Install the chart using:

```sh
helm install my-theia-cloud-base theia-cloud-repo/theia-cloud-base -f base-values.yaml
```

For a full list of customizable values, visit [theia-cloud-base chart documentation](https://github.com/eclipse-theia/theia-cloud-helm/blob/main/charts/theia-cloud-base/README.md).

### theia-cloud-crds

This chart focuses on Theia Cloud's CRDs and includes a service for version migration.
It's essential for maintaining custom resources within your cluster.

Installation commands:

```sh
kubectl create namespace my-namespace
helm -n my-namespace install my-theia-cloud-crds theia-cloud-repo/theia-cloud-crds
```

Refer to [theia-cloud-crds chart documentation](https://github.com/eclipse-theia/theia-cloud-helm/blob/main/charts/theia-cloud-crds/README.md) for customization details.

### theia-cloud

The main Theia Cloud chart installs the Operator and Service in your chosen namespace.
Begin by creating a `values.yaml` file with your desired configuration, e.g.:

```yaml
app:
  id: asdfghjkl
  name: My Theia

demoApplication:
  name: theiacloud/theia-cloud-demo
  timeout: "30"

hosts:
  usePaths: true
  configuration:
    baseHost: 12.345.67.89.sslip.io

keycloak:
  enable: false

operator:
  cloudProvider: "K8S"

ingress:
  controller: haproxy # or "nginx" (legacy)
  clusterIssuer: letsencrypt-prod
  theiaCloudCommonName: false
  addTLSSecretName: false

operatorrole:
  name: operator-api-access

servicerole:
  name: service-api-access
```

Customization Instructions:

- `app.id`: Generate a unique string for `app.id`. This identifier is public, so don't reuse a secret.
- Image Configuration: `demoApplication.name` allows you to specify a custom Docker image for Theia. Use `demoApplication.timeout` to define the session timeout, after which the application will automatically shut down.
- Host Configuration: The `hosts.configuration.baseHost` value has to be set to the hostname you want to use. An easy way to get started could be the public IP of your ingress controller. For example you may get this with:

```sh
# For HAProxy:
kubectl -n ingress-haproxy get service haproxy-ingress -o yaml

# For nginx:
kubectl -n ingress-nginx get service ingress-nginx-controller -o yaml
```

```yaml
# check the status for the public ip
status:
  loadBalancer:
    ingress:
      - ip: 12.345.67.89
```

```sh
# When using a minikube cluster, you may use
minikube ip
```

- Keycloak Integration: By setting `keycloak.enable` to `false`, you opt out of Keycloak integration. If you wish to utilize Keycloak for authentication, further configuration will be necessary. Please check out the options [here](https://github.com/eclipse-theia/theia-cloud-helm/blob/main/charts/theia-cloud/README.md) to learn about all Keycloak options.\
  For configuring Keycloak itself please have a look at the [oauth2-proxy documentation](https://oauth2-proxy.github.io/oauth2-proxy/configuration/providers/keycloak_oidc) and our [terraform Keycloak Example Realm configuration](https://github.com/eclipse-theia/theia-cloud/blob/main/terraform/modules/keycloak/main.tf).
- Cloud Provider Configuration: Adjust `operator.cloudProvider` to `MINIKUBE` if running on Minikube or leave the current value `K8S` for other clusters.
- Ingress and Security: `ingress.clusterIssuer` may have to be adjusted if a different issuer than the Let's encrypt issuer should be used or if it was installed with a different name. `ingress.theiaCloudCommonName` may have to be adjusted if the certificate created by the issuer misses the common name property.
- Roles Configuration: `operatorrole` and `servicerole` names might need adjustments if you adjusted the name during the base chart installation

After adjusting the values to your needs, install Theia Cloud with:

```sh
helm -n my-namespace install my-theia-cloud theia-cloud-repo/theia-cloud -f values.yaml
```

This setup enables access to the Theia Cloud sample landing page at <https://12.345.67.89.sslip.io/trynow/>.

For detailed installation instructions and customization options, visit [the main Theia Cloud chart documentation](https://github.com/eclipse-theia/theia-cloud-helm/blob/main/charts/theia-cloud/README.md).

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

## Update Theia Cloud

This section explains how to update your Theia Cloud deployment.
This includes updating values as well as upgrading to a new Theia Cloud version.
Similar to the installation, Helm is used for this.

Before moving to a new Theia Cloud version, you might want to have a look at the [Theia Cloud Helm changelog](https://github.com/eclipse-theia/theia-cloud-helm/blob/main/CHANGELOG.md). If you customized core components (e.g. the operator), you also might want to look at [Theia Cloud's code changelog](https://github.com/eclipse-theia/theia-cloud/blob/main/CHANGELOG.md).

**Upgrading to 1.2.0:** The nginx ingress path regex pattern changed from `($|(/.*))` to `(/|$)(.*)` and the `rewrite-target` annotation now uses `$1$2` instead of `$1`. This maintains the same functionality but users with custom nginx configurations relying on the capture group numbering may need to adjust. See the [changelog](https://github.com/eclipse-theia/theia-cloud-helm/blob/main/CHANGELOG.md) for details.

Make sure you have the Theia Cloud helm charts available and updated as described in section [Theia Cloud Helm Charts](#theia-cloud-helm-charts).
In short:

```bash
# First time only
helm repo add theia-cloud-repo https://eclipse-theia.github.io/theia-cloud-helm

# Update the helm repo
helm repo update
```

You may inspect the available chart versions with:

```bash
helm search repo theia-cloud-repo --versions
```

For the following update steps, we assume that you named your values files and Helm installations as in section [Theia Cloud Helm Charts](#theia-cloud-helm-charts).

**Note:** Even if you only want to update the values of your Theia Cloud installation, Helm upgrades to the latest version of the chart by default.
To stay on the current version or upgrade to a specific version, use the `--version` option of `helm upgrade`.
For more information see the official Helm upgrade documentation: <https://helm.sh/docs/helm/helm_upgrade/>.

Instructions to upgrade the charts:

```bash
# Base chart
helm upgrade my-theia-cloud-base theia-cloud-repo/theia-cloud-base -f base-values.yaml

# CRD chart
helm -n my-namespace upgrade my-theia-cloud-crds theia-cloud-repo/theia-cloud-crds

# Main chart
helm -n my-namespace upgrade my-theia-cloud theia-cloud-repo/theia-cloud -f values.yaml
```

Instructions to upgrade the charts to a specific Theia Cloud version (here 0.10.0):

```bash
# Base chart
helm upgrade my-theia-cloud-base theia-cloud-repo/theia-cloud-base -f base-values.yaml --version 0.10.0

# CRD chart
helm -n my-namespace upgrade my-theia-cloud-crds theia-cloud-repo/theia-cloud-crds --version 0.10.0

# Main chart
helm -n my-namespace upgrade my-theia-cloud theia-cloud-repo/theia-cloud -f values.yaml --version 0.10.0
```
