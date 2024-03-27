+++
fragment = "content"
weight = 100

title = "More Documentation"

[sidebar]
  sticky = true
+++

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

## Custom Session Parameters

This tutorial describes how custom parameters are injected into session pods as environment variables.
This may be used to inject parameters into a session that are not equal for all sessions of an app definition.
For instance, access tokens or dynamic parameters such as a Git repository to check out.

#### Adding environment variables via REST API

The simplest way to start a Session with custom environment variables is using Theia Cloud's REST API.
Theia Cloud offers npm package [@eclipse-theiacloud/common](https://www.npmjs.com/package/@eclipse-theiacloud/common) to access the REST API conveniently.
It offers to provide environment variables directly or as lists of [config maps](https://kubernetes.io/docs/concepts/configuration/configmap/) or [secrets](https://kubernetes.io/docs/concepts/configuration/secret/) to read in.

The following code snippet shows how to add environment variables while starting a session.
Thereby, the whole `env` as well as its three properties `fromMap`, `fromConfigMaps` and `fromSecrets` are optional.
The snippet assumes that the parameters `accessToken` and `user` are present as variables based on the authenticated user.
You can have a look at the [Try Now Page](https://github.com/eclipsesource/theia-cloud/blob/main/node/try-now-page/src/App.tsx) to see an example of how these are derived when logging in via Keycloak.

```typescript
import { getTheiaCloudConfig, SessionStartRequest, TheiaCloud } from '@eclipse-theiacloud/common';

// Get common parameters from Theia Cloud configuration
const { appDefinition, appId, serviceUrl } = getTheiaCloudConfig();

// Create request object with customized environment variables
// user and accessToken are expected to be set based on the authenticated user
const request: SessionStartRequest = {
  serviceUrl,
  accessToken,
  appId,
  user,
  appDefinition,
  env: {
    fromMap: {
      mykey: "myvalue"
    },
    fromConfigMaps: [ "session-config-map-1", "config-map-2" ],
    fromSecrets: [ "session-secret-1", "session-secret-2" ]
  }
}

// Send request
TheiaCloud.Session.startSession(request);
```

#### Adding environment variables via Session CR

The environment variables can also be configured directly through the Session custom resource by adding one or multiple of the following properties:

- [envVars](https://github.com/eclipsesource/theia-cloud-helm/blob/4cd9d98d30cebe8d31e7084369878c1c2d28776c/charts/theia-cloud-crds/templates/session-spec-resource.yaml#L46-L49): This property is a map that allows you to define environment variables directly. Each entry in the map consists of the environment variable name and its value. This method is suitable for standard configuration needs and facilitates individual configuration for each session.

- [envVarsFromConfigMaps](https://github.com/eclipsesource/theia-cloud-helm/blob/4cd9d98d30cebe8d31e7084369878c1c2d28776c/charts/theia-cloud-crds/templates/session-spec-resource.yaml#L50-L53): For environment variables that need to be sourced from existing Kubernetes config maps, this property allows you to specify a list of config maps from which to read. This approach is particularly useful for sharing common configuration across multiple sessions or applications.

- [envVarsFromSecrets](https://github.com/eclipsesource/theia-cloud-helm/blob/4cd9d98d30cebe8d31e7084369878c1c2d28776c/charts/theia-cloud-crds/templates/session-spec-resource.yaml#L54-L57): Similar to `envVarsFromConfigMaps`, this property lets you define a list of Kubernetes secrets from which to read environment variables. This method is a good fit for sensitive information such as credentials, ensuring that such details are managed securely and in accordance with Kubernetes best practices.

#### Accessing environment variables in Theia

With the additional environment variables injected into Theia, they can now be read in your Theia extension.
This is facilitated by Theia's `EnvVariablesServer` like the following.

```typescript
import { injectable, inject} from 'inversify';
import { EnvVariablesServer } from '@theia/core/lib/common/env-variables';

@injectable()
export class MyEnvProcessor {

  constructor(
    @inject(EnvVariablesServer) protected readonly environments: EnvVariablesServer
  ) { }

  readCustomEnvironmentVariables() {
    // Read environment variable with key MYKEY
    const myValue = environments.getValue('MYKEY');
  }
}
```

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

## Operator Pattern

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
