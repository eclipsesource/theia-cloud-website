+++
fragment = "content"
weight = 100

title = "Operator Pattern"

[sidebar]
  sticky = true
+++

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

In the operator pattern, an operator is a specialized software added to Kubernetes.
It utilizes custom resources (CRs) to manage applications and their components more effectively.

Essentially, an operator is a specific type of controller for applications, simplifying the setup, configuration, and management of stateful applications by extending the Kubernetes API.
This method builds on the basic concepts of Kubernetes resources and controllers but also allows for the inclusion of domain or application-specific knowledge.
Operators monitor custom resources, which are extensions of the Kubernetes API that represent the desired state of the application.
The operator then manages Kubernetes resources based on the configurations specified in these CRs.

The key components of this pattern are:

- **Custom Resource Definitions (CRDs):** These define the schema for custom resources, allowing the Kubernetes API to recognize and manage them.
- **Custom Resources (CRs):** Extensions of the Kubernetes API, these resources contain the configuration and operational state of an application, based on a specific CRD.
- **Operator:** This component continuously monitors the CRs, making adjustments to the application to ensure it matches the user-defined desired state.
