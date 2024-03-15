+++
fragment = "content"
weight = 100

title = "Try Theia Cloud"

[sidebar]
  sticky = true
+++

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

## On your Machine with Minikube

Welcome to the setup guide for Theia Cloud on a Kubernetes cluster using Minikube. This tutorial covers the installation of Theia Cloud with Keycloak authentication, launching a Theia IDE instance in a "try now" format for 30-minute explorations. It's a foundational setup that can be customized to include your applications, custom landing page, adjusted usage limits, or specific user authentication.

➡️ Please have a look at the [Overview]({{< relref "overview" >}}) section when you want to learn more about the basics of Theia Cloud.

### Prerequisites

This section shortly explains which tools have to be installed so that you can follow the guide.

#### Install Minikube

Minikube is a local Kubernetes cluster aimed at helping developers to learn and develop for Kubernetes.

The official installation instructions can be found here: <https://minikube.sigs.k8s.io/docs/start/>

#### Install Virtualbox

Minikube can be deployed in different ways, e.g. using a virtual machine, a container, or running on bare-metal.\
For this guide we will run Minikube in a Virtualbox VM, since this driver is available on most operating systems and offers the Kubernetes features we need.\
If you are not able to use Virtualbox on your system, please see [How to use a Minikube driver other than Virtualbox](#how-to-use-a-minikube-driver-other-than-virtualbox).

Please download and install virtualbox as described here: <https://www.virtualbox.org/wiki/Downloads>

#### Download Minikube Virtualbox Driver

The driver can be downloaded via minikube like this

```bash
minikube start --vm=true --driver=virtualbox --download-only
```

#### Install Terraform

We use Terraform configuration files to manage infrastructure and installations in a human readable way.

You can download and install Terraform as described here: <https://developer.hashicorp.com/terraform/install?product_intent=terraform>

#### Checkout Theia Cloud Repository

Finally, please check out our git repositories. The repositories contain the terraform configuration files used in this guide.

```bash
git clone https://github.com/eclipsesource/theia-cloud.git
```

### Run the Getting Started Guide

Now we may finally create our local cluster and install Theia Cloud including all of its dependencies. With our terraform configuration this may be done with just a few commands on the terminal:

```bash
# cd into the checked out theia-cloud directory, from there:
cd terraform/configurations/minikube_getting_started/

# download required providers
terraform init

# create the cluster
# You will be asked for an email address used by the cert-manager to contact you about expiring certs.
# Enter yes at the end
terraform apply
```

This will now run for a few minutes. During this time it will

* Create a Virtualbox VM running the Kubernetes Cluster
* Install a number of tools in the cluster using helm
  * cert-manager for managing Certificates
  * nginx-ingress-controller for exposing HTTP(S) routes via NginX
  * keycloak for managing authentication
  * Theia Cloud
* Creates a few default users on Keycloak
  * foo (password: foo)
  * bar (password: bar)

At the end you will see a similar output to this:

```bash
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

try_now = "https://192.168.59.105.nip.io/trynow/"
```

Point your browser to the “try_now” URL and accept the self signed certificate.\
This will then redirect you to Keycloak where you may login using one of the two users above.\
After successful authentication a sample “Eclipse Theia IDE” will be launched for you.

### Troubleshooting

This section covers common pitfalls that were reported to us.

#### How to use a Minikube driver other than Virtualbox

In order to try a different driver than Virtualbox open `terraform/configurations/minikube_getting_started/minikube_getting_started.tf` and adjust

```bash
driver       = "virtualbox" 
```

to your desired driver.\
You should also download the driver image beforehand, similar to:

```bash
minikube start --vm=true --driver=virtualbox --download-only
```

You can find the list of drivers here: <https://minikube.sigs.k8s.io/docs/drivers/>
