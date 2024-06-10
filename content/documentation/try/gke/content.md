+++
fragment = "content"
weight = 100

title = "Try Theia Cloud on GKE"

[sidebar]
  sticky = true
+++

<img src="../../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

Welcome to the setup guide for Theia Cloud on a Kubernetes cluster using Google Kubernetes Engine (GKE).
This tutorial covers the installation of Theia Cloud with Keycloak authentication, launching a Theia IDE instance in a “try now” format for 30-minute explorations.
It’s a foundational setup that can be customized to include your applications, custom landing page, adjusted usage limits, or specific user authentication.

➡️ Please have a look at the [Overview]({{< relref "overview" >}}) section when you want to learn more about the basics of Theia Cloud.

#### Prerequisites

This section shortly explains which tools have to be installed so that you can follow the guide.

##### Install Terraform

We use Terraform configuration files to manage infrastructure and installations in a human readable way.

You can download and install Terraform as described here: <https://developer.hashicorp.com/terraform/install>

##### Setup GKE and Google Cloud SDK

We expect users to have basic experience with GKE: <https://cloud.google.com/kubernetes-engine>.
You may want to check their guides as a new user first: <https://cloud.google.com/kubernetes-engine/docs/deploy-app-cluster>

Please note that using our configurations may cause you cost depending ob whether the free credit provided for new GKE users was used up already.

Our terraform modules expect you to have the Google Cloud SDK installed and set up: <https://cloud.google.com/sdk>

##### Checkout Theia Cloud Repository

Finally, please check out our git repository. The repository contains the terraform configuration files used in this guide.

```bash
git clone https://github.com/eclipsesource/theia-cloud.git
```

#### Run the Getting Started Guide

Now, we may finally create our GKE cluster and install Theia Cloud including all of its dependencies.
This is going to create a new cluster named `gke-theia-cloud-getting-started` in your Google Cloud project.
With our terraform configuration this may be done with just a few commands on the terminal:

```bash
# cd into the checked out theia-cloud directory, from there:
cd terraform/configurations/gke_getting_started/

# download required providers
terraform init

# Create the cluster
# You will be asked for an email address used by the cert-manager to contact you about expiring HTTPS certificates.
# Furthermore, you are asked for a password for the Keycloak Admin User, the Postgres DB and the Postgres Admin User.
# Finally, you have to pass the id of your Google Cloud Project in which the cluster will be created.
# Enter yes at the end to create and setup the cluster.
terraform apply
```

This will now run for a few minutes. During this time it will

- Create a GKE cluster named `gke-theia-cloud-getting-started`
- Install a number of tools in the cluster using helm
  - cert-manager for managing Certificates
  - nginx-ingress-controller for exposing HTTP(S) routes via NginX
  - Keycloak for managing authentication
  - Theia Cloud
- Creates a few default users on Keycloak
  - foo (password: foo)
  - bar (password: bar)

After the installation finished, you will see output similar to this:

```bash
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

try_now = "https://34.145.38.245.sslip.io/trynow/"
```

Point your browser to the “try_now” URL.
This redirects you to Keycloak where you may login using one of the two users above.
After successful authentication, a sample “Eclipse Theia IDE” will be launched for you.

#### Destroy GKE Cluster

This deletes the cluster and stops all running sessions.

```bash
terraform destroy
```

#### GKE Troubleshooting

This section covers common pitfalls that were reported to us.

##### OAuth errors during setup

If you get OAuth related errors when using the terraform google provider, although you are sucessfully logged in via the Google Cloud CLI, try to export the `GOOGLE_OAUTH_ACCESS_TOKEN` env variable.

```bash
GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token) terraform apply
```
