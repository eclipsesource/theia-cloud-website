+++
fragment = "content"
title = "Overview"
weight = 100
[sidebar]
  sticky = true
+++

Theia Cloud is a framework designed to build hosting services for Theia-based applications, IDEs, and tools.

The primary goal of this project is to simplify the deployment process of Theia-based products, ensuring a smooth learning curve for new adopters while providing robust out-of-the-box features.
At the same time, we aim for flexibility, allowing for extensive customization and extensibility.

Theia Cloud is both running on and facilitates hosting of Theia-based applications using Kubernetes, employing the operator pattern for efficient management.

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

Within Theia Cloud, we introduce three custom Kubernetes resource types through our operator:

* **App Definitions**: These resources encapsulate all necessary information about custom Theia-based products, such as the container images to use and resource requirements.
* **Workspaces**: These define persistent storage solutions that are owned by and can be reused by specific users.
* **Sessions**: Acting as runtime representations of Theia-based products, sessions merge information from App Definitions with Workspaces, alongside other runtime details.

The components of Theia Cloud include:

* **A Landing Page**: Utilizes Theia Cloud Common API npm package for integration into any webpage.
* **Theia Cloud REST Service**: An API for session requests and management, called by the npm package.
* **Theia Cloud Operator**: The core component responsible for deploying sessions and managing workspaces.
* **Authentication and Authorization**: Implemented via a reverse proxy using OAuth2 for secure access.
* **Theia Cloud Monitor**: An optional component for monitoring application aspects, such as user activity.

A simplified diagram illustrating the interaction between these components is provided below:

<img src="../../images/theia-cloud-components.svg" alt="Theia Cloud Overview" width="800" style="display: block; margin: auto;" />

Users initiate the creation of a Workspace and a Session for an existing App Definition through the Landing Page, utilizing the Theia Cloud Service.
This Service then generates custom resource objects for both the Workspace and the Session.
Upon creation of these resources, the Operator is notified and proceeds to create various kubernetes resources, including a new Persistent Volume and a Deployment for the Theia-based product.
These components are configured based on the information provided in the Session, Workspace, and App Definition.

Once the Theia-based product is operational, the operator updates the session's runtime state with the accessible URL.
The Service captures this URL and communicates it back to the Landing Page, which in turn redirects the user to their newly launched environment.
Throughout this process, authentication and authorization are applied to ensure secure access.

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

Our objective is to ensure Theia Cloud's App Definition Model is ready to accommodate most use cases right out of the box.
Additionally, we aim to provide Kubernetes Resources that are ready and tested for production use.

However, we recognize that no single solution can meet all needs.
With customization and extensibility as priorities, the Theia Cloud Operator has been developed to support various levels of modification, including the replacement of template files for creating new Deployments, Services, or Ingresses.
These templates are designed to closely mimic standard Kubernetes YAML files, requiring no additional programming knowledge.

For more advanced customizations, the operator is also available as a Java library.
This allows users to tailor virtually any aspect of the application to their needs, facilitated by dependency injections and service interfaces for seamless integration.

Please be aware that Theia Cloud is still under active development.
While we have designed the architecture with these considerations in mind, comprehensive documentation and a finalized extension API are forthcoming.
We are diligently working to enhance our documentation and API.
Should you require assistance or access to specific APIs sooner, please explore our [available support options]({{< relref "/support" >}}).
