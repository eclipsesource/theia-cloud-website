+++
fragment = "content"
title = "Try Theia Cloud"
weight = 100
[sidebar]
  sticky = true
+++

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

Currently, we offer two preconfigured configurations for installing and trying out Theia Cloud on a cluster.
Additionally, we have a running version available at [try.theia-cloud.io](https://try.theia-cloud.io/).

The preferred option is using the [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine).
While this is a paid service, new customers receive a $300 credit, which is sufficient to try Theia Cloud.
Please check out our [GKE Guide]({{< relref "../../try/gke/" >}}).

Our second option uses Minikube, a local one-node Kubernetes cluster intended for testing only.
Our Minikube configuration is extensively tested on Linux (Ubuntu) and is expected to work well on this OS.
It should also be possible to run it on Windows and macOS; however, we cannot support the setup on these systems.
Our Minikube Guide can be found [here]({{< relref "../../try/minikube/" >}}).

If you need to try Theia Cloud on a different cluster than GKE or Minikube, please have a look at the [Installation Guide]({{< relref "setuptheiacloud" >}}).
