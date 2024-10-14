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
You can have a look at the [Try Now Page](https://github.com/eclipsesource/theia-cloud/blob/main/node/landing-page/src/App.tsx) to see an example of how these are derived when logging in via Keycloak.

```typescript
import {
  getTheiaCloudConfig,
  SessionStartRequest,
  TheiaCloud,
} from "@eclipse-theiacloud/common";

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
      mykey: "myvalue",
    },
    fromConfigMaps: ["session-config-map-1", "config-map-2"],
    fromSecrets: ["session-secret-1", "session-secret-2"],
  },
};

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
import { injectable, inject } from "inversify";
import { EnvVariablesServer } from "@theia/core/lib/common/env-variables";

@injectable()
export class MyEnvProcessor {
  constructor(
    @inject(EnvVariablesServer)
    protected readonly environments: EnvVariablesServer
  ) {}

  readCustomEnvironmentVariables() {
    // Read environment variable with key MYKEY
    const myValue = environments.getValue("MYKEY");
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

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

## Custom Certificates

Our default installation includes basic support for Let's Encrypt certificates.
However, more advanced use cases, such as wildcard certificates, require specific configuration allowing the cert-manager to update DNS entries (see [here](https://cert-manager.io/docs/configuration/acme/dns01/)) to obtain valid certificates from Let's Encrypt.
To support this, you can create your own cluster issuer and pass the name to Theia Cloud using the [`ingress.clusterIssuer` helm value](https://github.com/eclipsesource/theia-cloud-helm/tree/main/charts/theia-cloud#readme).

In a production environment, you often have existing certificates you want to use.
For this, we have the `ingress.certManagerAnnotations` helm value, which can be set to `false` to avoid adding any cert-manager-related annotations on the ingress.
For path-based installations, where our default templates don't add TLS secret names, you can enable them by setting `hosts.paths.tlsSecretName` to `true`.

The landing page will use the certificate from a secret called `landing-page-cert-secret`, the REST service from the `service-cert-secret`, and the instances ingress from the `ws-cert-secret`.

You can then import your certificates as described in the [Kubernetes documentation](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_secret_tls/), e.g.

```sh
kubectl -n theiacloud create secret tls service-cert-secret --cert=/home/user/certificate/service3.my-theia-cloud.io/fullchain1.pem --key=/home/user/certificate/service3.my-theia-cloud.io/privkey1.pem
kubectl -n theiacloud create secret tls landing-page-cert-secret --cert=/home/user/certificate/landing3.my-theia-cloud.io/fullchain1.pem --key=/home/user/certificate/landing3.my-theia-cloud.io/privkey1.pem
kubectl -n theiacloud create secret tls ws-cert-secret --cert=/home/user/certificate/webview.ws3.my-theia-cloud.io/fullchain1.pem --key=/home/user/certificate/webview.ws3.my-theia-cloud.io/privkey1.pem
```

#### Manual Wild Card Certificates using Let's Encrypt

For testing purposes, it is convenient to create temporary certificates using Let's Encrypt.
This assumes that Certbot is installed on your system.

You can initiate a manual challenge with the following command:

```sh
sudo certbot certonly --manual --preferred-challenges=dns --email jdoe@theia-cloud.io --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d *.webview.ws3.my-theia-cloud.io -d ws3.my-theia-cloud.io
```

Certbot will provide the DNS TXT records that need to be created, for example:

```sh
Please deploy a DNS TXT record under the name:

_acme-challenge.webview.ws3.my-theia-cloud.io.

with the following value:
....

```

Follow the instructions until you receive your certificates.
Remember to remove the TXT records after your certificate has been issued.

## Logout

In Theia Cloud, logging out properly involves a sequential logout from both Keycloak and the [OAuth2 Proxy](https://oauth2-proxy.github.io/oauth2-proxy/) that protects the session pods.

The primary login is handled by Keycloak, and the OAuth2 Proxy verifies the user session against Keycloak, setting a separate authentication cookie.
To fully log out, users must not only log out of Keycloak but also clear the OAuth2 Proxy authentication cookie. This requires a logout from both services.

To simplify this process, you can clear both login tokens with a single link by first redirecting the user to the OAuth2 Proxy logout URL, which will then redirect them to the Keycloak logout URL.
After the logout from Keycloak, the user is redirected back to the landing page.

### Constructing the logout URL

Each Theia session has its own OAuth2 Proxy instance. The OAuth2 Proxy logout URL is available at the subpath `./oauth2/sign_out` of the user's session URL.
Therefore, in this guide, we assume that the logout action is initiated from within the session pod (i.e., from the running Theia instance).

To construct the complete logout URL, use the Keycloak logout URL as the `rd` (redirect) parameter of the OAuth2 Proxy logout URL. Then, specify the landing page URL as the `post_logout_redirect_uri` in the Keycloak logout URL.

#### Example Scenario

Let's assume the following URLs for a typical Theia Cloud deployment:

- **Landing page**: `https://example.com/start`
- **Sessions base**: `https://example.com/instances`
- **Sample session**: `https://example.com/instances/34d121da-ffc1-480c-a89b-f6d259c6df9f`
- **Keycloak**: `https://example.com/keycloak`

Furthermore, assume that Keycloak uses the `TheiaCloud` realm for managing Theia Cloud users.

#### Example JavaScript Code for Logout URL Construction

Because query parameters must be URL-encoded, both the Keycloak URL and the landing page URL need to be encoded.
You can use JavaScript's [encodeURIComponent](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent) method to handle the encoding.
Note that `encodeURI` is not appropriate here because we're encoding the URLs as query parameters.

Here’s how you can construct the logout URL for the example deployment:

```js
// Encode the landing page URL to use as a query parameter
const encodedLandingPageUrl = encodeURIComponent("https://example.com/start");

// Encode the Keycloak logout URL, which includes the landing page URL as a redirect.
// This results in the landing page URL being double-encoded, which is intentional.
const encodedKeycloakUrl = encodeURIComponent(
  `https://example.com/keycloak/realms/TheiaCloud/protocol/openid-connect/logout?client_id=theia-cloud&post_logout_redirect_uri=${encodedLandingPageUrl}`
);

// Relative logout URL to be used from within the Theia IDE session.
// Assign the encoded Keycloak logout url to the `rd` query parameter
const logoutUrl = `./oauth2/sign_out?rd=${encodedKeycloakUrl}`;
```

### Additional Resources

For more information on the relevant logout endpoints, refer to the following resources:

- [OAuth2 Proxy Logout Endpoint Documentation](https://oauth2-proxy.github.io/oauth2-proxy/features/endpoints#sign-out)
- [Keycloak OpenID Connect Logout Endpoint Documentation](https://www.keycloak.org/docs/latest/securing_apps/#logout-endpoint)
