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
Please have a look at the [Helm configuration](https://github.com/eclipsesource/theia-cloud/blob/main/terraform/modules/helm/main.tf) to find the used values.

### cert-manager.io

For certificate management, we use [cert-manager.io](https://cert-manager.io/).

We offer the installation of two cluster issuers: a self-signed issuer for testing and cluster internal usage, and an issuer for creating Let's Encrypt certificates.
You may use your existing cluster issuers as well!

We suggest installing the cert-manager using [the official Helm chart](https://cert-manager.io/docs/installation/helm/).

### ingress-nginx

By default, the ingresses installed with the Theia Cloud Helm charts and created by the Theia Cloud operator use the [Ingress NGINX Controller](https://kubernetes.github.io/ingress-nginx/).

You can find the official deployment instructions [here](https://kubernetes.github.io/ingress-nginx/deploy/).

*Please note that it is possible to integrate other types of ingresses into Theia Cloud as well, and this is part of our roadmap. We do not offer documentation and finalized APIs for this yet, however. If you need this feature sooner, please see our [available support options]({{< relref "/support" >}}).*

### Keycloak (optional)

If your use case requires user management, we recommend the use of [Keycloak](https://www.keycloak.org/). Keycloak acts as an OAuth2 provider, and it is possible to integrate other existing providers into Keycloak.

We suggest using the [Bitnami Helm chart](https://github.com/bitnami/charts/tree/main/bitnami/keycloak) for Keycloak.

*Please note that it is possible to integrate any OAuth2 provider with Theia Cloud, and this is part of our roadmap. We do not offer documentation and finalized APIs for this yet, however. If you need this feature sooner, please see our [available support options]({{< relref "/support" >}}).*

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

## Theia Cloud Helm Charts

Theia Cloud offers three helm charts that are available via the helm repository hosted at <https://github.eclipsesource.com/theia-cloud-helm/>.

* `theia-cloud-base`: Cluster wide resources, like issuers and roles used by Theia Cloud
* `theia-cloud-crds`: Theia Cloud Custom Resource Definitions and their conversion webhook
* `theia-cloud`: The main helm chart including Operator and Service

The Helm repository may be added like this:

```sh
helm repo add theia-cloud-repo https://github.eclipsesource.com/theia-cloud-helm
```

If you added the repository earlier already, please run `helm repo update` to get the latest charts for all repositories.

*Please note that we are working on making the chart contents as customizable as possible and to add the possibility to skip any optional resources. If you need some changes earlier, please see our [available support options]({{< relref "/support" >}}).*

In this part of the documentation we will give you an overview over the different helm charts with a simple sample configuration.
We cannot explain every possible value within this guide.
We will offer links to the value documentation for each chart.
Besides that please also take a look at our [terraform getting started configurations](https://github.com/eclipsesource/theia-cloud/tree/main/terraform/configurations).
These will create full Theia Cloud installations on different cluster providers, currently for GKE and Minikube.
You can use these configuration as starting points for your setup.
We plan to offer more configurations in the future.

*If you need an example for a specific cluster provider earlier, please see our [available support options]({{< relref "/support" >}}).*

### theia-cloud-base

The goal of this chart is to install cluster-wide resources that are not bound to a namespace.

At the moment there are two `ClusterIssuer`s, one creating self-signed certificates and one creating let's encrypt certificates. Moreover we install two `ClusterRole`s for the Theia Cloud Operator and the Theia Cloud Service.

Create a file called `base-values.yaml` with the following contents (enter your mail address):

```yaml
issuer:
  email: j.doe@theia-cloud.io
```

*The full list of possible values that can be customized can be found [here](https://github.com/eclipsesource/theia-cloud-helm/blob/main/charts/theia.cloud-base/README.md). You can customize the name of the cluster-wide resources in order to avoid potential conflicts.*

Then install with:

```sh
helm install my-theia-cloud-base theia-cloud-repo/theia-cloud-base -f base-values.yaml
```

### theia-cloud-crds

This chart contains everything related to Theia Cloud's custom resource definitions. While the CRDs itself are cluster-wide, we also have a service that can migrate between different versions.

*The full list of possible values that can be customized can be found [here](https://github.com/eclipsesource/theia-cloud-helm/blob/main/charts/theia-cloud-crds/README.md). By default we try to use the self-signed issuer installed with the base chart. If the `issuerstaging.name` values was adjusted in the base chart installation, the `clusterIssuer` value has to be adjusted here as well. Other values than can be customized are about the image for the conversion webhook.*

You can install the CRDs with:

```sh
kubectl create namespace my-namespace
helm -n my-namespace install my-theia-cloud-crds theia-cloud-repo/theia-cloud-crds
```

### theia-cloud

Finally the Theia Cloud main chart. This will install Theia Cloud in the provided namespace.

Please create a file called `values.yaml` with the contents below.
You can find the full list of possible values that can be customized [here](https://github.com/eclipsesource/theia-cloud-helm/blob/main/charts/theia.cloud/README.md).

```yaml
app:
  id: asdfghjkl
  name: My Theia

image:
  name: theiacloud/theia-cloud-demo
  timeout: "30"

hosts:
  usePaths: true
  paths:
    baseHost: 12.345.67.89.sslip.io

keycloak:
  enable: false

operator:
  cloudProvider: "K8S"

ingress:
  clusterIssuer: letsencrypt-prod
  theiaCloudCommonName: false

operatorrole:
  name: operator-api-access

servicerole:
  name: service-api-access
```

Please exchange `app.id` with a generated string. This is public though, so do not use a secret!

In `image.name` and `image.timeout` you can configure a custom Theia docker image to use and a time after which sessions will get shut down automatically.

You have to adjust the `hosts.paths.baseHost` value. As a starting point you could start with the public ip of the ingress controller. Run

```sh
kubectl -n ingress-nginx get service ingress-nginx-controller -o yaml
```

and check out the status object, e.g.:

```yaml
status:
  loadBalancer:
    ingress:
    - ip: 12.345.67.89
```

On Minikube you would get this with `minikube ip`. You may then use e.g. `12.345.67.89.sslip.io` as the hostname.

Here we disable Keycloak with `keycloak.enable`. Please check out the options [here](https://github.com/eclipsesource/theia-cloud-helm/blob/main/charts/theia.cloud/README.md) to learn about all Keycloak options.
For configuring Keycloak itself please have a look at the [oauth2-proxy documentation](https://oauth2-proxy.github.io/oauth2-proxy/configuration/providers/keycloak_oidc) and our [terraform Keycloak Example Realm configuration](https://github.com/eclipsesource/theia-cloud/blob/main/terraform/modules/keycloak/main.tf).

If you are trying this with Minikube. please adjust `operator.cloudProvider` to `MINIKUBE`. Keep as `K8S` otherwise.

`ingress.clusterIssuer` may have to be adjusted if a different issuer than the Let's encrypt issuer should be used or if it was installed with a different name. `ingress.theiaCloudCommonName` may have to be adjusted if the certificate created by the issuer misses the common name property.

`operatorrole` and `servicerole` may have to be adjusted of different names were used in the base chart.

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

After the values were adjusted to your needs, you may install Theia Cloud with:

```sh
helm -n my-namespace install my-theia-cloud theia-cloud-repo/theia-cloud -f values.yaml
```

With above values the Theia Cloud sample landing page will be running at <https://12.345.67.89.sslip.io/trynow/>.
