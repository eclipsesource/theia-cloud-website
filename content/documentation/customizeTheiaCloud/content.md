+++
fragment = "content"
weight = 100

title = "Customize Theia Cloud"

[sidebar]
  sticky = true
+++

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

## Landing Page

Theia Cloud does not offer a dashboard for launching, stopping, and managing sessions and workspaces for each user.
Experience has shown that requirements for branding, styling, feature sets, and workflows vary significantly.
As a result, providing a fully white-labeled dashboard often does not meet all the unique requirements.
Therefore, Theia Cloud focuses on providing TypeScript APIs and libraries that allow users to easily interact with Theia Cloud Services.
This approach enables users to create their own landing page or to integrate Theia Cloud in existing web applications.

To get started or for demonstration purposes, you may want to explore [our sample landing page](https://github.com/eclipsesource/theia-cloud/tree/main/node/try-now-page).

### Simple Customizations

This section briefly explains how you can customize the sample landing page using helm values when installing the `theia-cloud` helm chart.

```yaml
app:
  name: Theia Blueprint
  logoData: ICA8c3ZnIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogICAgeD0iMCIgeT0iMCIgcHJlc2VydmVBc3BlY3RSYXRpbz0ieE1pbllNaW4gbWVldCIKICAgIHZpZXdCb3g9IjAsIDAsIDExNTAsIDU0MC42Ij4KICAgIDxnIGlkPSJMYXllcl8xIiBmaWxsPSIjMGQ4MmZmIj4KICAgICAgPHBhdGgKICAgICAgICBkPSJNODgwLjE5OSwyLjggQzEwMjguMSwyLjggMTE0Ny45LDEyMi42IDExNDcuOSwyNzAuNSBDMTE0Ny45LDQxOC4zIDEwMjguMSw1MzguMiA4ODAuMiw1MzguMiBMMjkwLjEsNTM4LjIgQzI2OSw1MzguMiAyNTEuOSw1MjEuMSAyNTEuOSw1MDAgQzI1MS45LDQ3OC45IDI2OSw0NjEuOCAyOTAuMSw0NjEuOCBMNDI3LjYsNDYxLjggQzQ0OC42LDQ2MS44IDQ2NS43LDQ0NC43IDQ2NS43LDQyMy42IEM0NjUuNyw0MDIuNSA0NDguNiwzODUuNCA0MjcuNiwzODUuNCBMMzk2Ljk5OSwzODUuNCBDMzc1LjksMzg1LjQgMzU4LjgsMzY4LjMgMzU4LjgsMzQ3LjIgQzM1OC44LDMyNi4xIDM3NS45LDMwOSAzOTcsMzA5IEw0ODguNzAzLDMwOSBDNTA5LjkxOCwzMDguOTQxIDUyNi4zNzMsMjkxLjY1IDUyNi45LDI3MC44IEM1MjYuOSwyNDkuNyA1MDkuOCwyMzIuNiA0ODguNywyMzIuNiBMMTY3LjgsMjMyLjYgQzE0Ni43LDIzMi42IDEyOS42LDIxNS41IDEyOS42LDE5NC40IEMxMjkuNiwxNzMuMyAxNDYuNywxNTYuMiAxNjcuOCwxNTYuMiBMNDA0LjYwNCwxNTYuMiBDNDI1LjgxOCwxNTYuMTQxIDQ0Mi4yNzMsMTM4Ljg1IDQ0Mi44LDExOCBDNDQyLjgsOTYuOSA0MjUuNyw3OS44IDQwNC42LDc5LjggTDM1MS4yLDc5LjggQzMzMC4xLDc5LjggMzEzLDYyLjcgMzEzLDQxLjYgQzMxMywyMC41IDMzMC4xLDIuNCAzNTEuMiwyLjQgTDg4MC4xOTksMi44IHogTTgzNy40LDkyIEw4MzcuNCw5MiBDNzU1LjIsOTIgNjg4LjcsMTU4LjYgNjg4LjcsMjQwLjcgTDY4OC43LDMwMC4yIEM2ODguNywzODIuNCA3NTUuMiw0NDguOSA4MzcuNCw0NDguOSBDOTE5LjUsNDQ4LjkgOTg2LjEsMzgyLjQgOTg2LjEsMzAwLjIgTDk4Ni4xLDI0MC43IEM5ODYuMSwxNTguNiA5MTkuNSw5MiA4MzcuNCw5MiBMODM3LjQsOTIgeiBNODg4LjIsMjMyLjYgQzkwOCwyMzIuNiA5MjQuMSwyNDguNyA5MjQuMSwyNjguNSBMOTI0LjEsMjczLjEgQzkyNC4xLDI5Mi45IDkwOCwzMDkgODg4LjIsMzA5IEw3NzYuNiwzMDkgQzc1Ni44LDMwOSA3NDAuNywyOTIuOSA3NDAuNywyNzMuMSBMNzQwLjcsMjY4LjUgQzc0MC43LDI0OC43IDc1Ni44LDIzMi42IDc3Ni42LDIzMi42IEw4ODguMiwyMzIuNiB6IiAvPgogICAgICA8cGF0aAogICAgICAgIGQ9Ik0xNzAuMSw0NjEuOCBDMTkwLDQ2MS44IDIwNiw0NzcuOCAyMDYsNDk3LjcgTDIwNiw1MDIuMyBDMjA2LDUyMi4xIDE5MCw1MzguMiAxNzAuMSw1MzguMiBMMzgsNTM4LjIgQzE4LjIsNTM4LjIgMi4xLDUyMi4xIDIuMSw1MDIuMyBMMi4xLDQ5Ny43IEMyLjEsNDc3LjggMTguMiw0NjEuOCAzOCw0NjEuOCBMMTcwLjEsNDYxLjggeiIgLz4KICAgICAgPHBhdGgKICAgICAgICBkPSJNMjMxLjMsMy40IEMyNTEuMSwzLjQgMjY3LjEsMTkuNSAyNjcuMSwzOS4zIEwyNjcuMSw0NCBDMjY3LjEsNjMuOCAyNTEuMSw3OS44IDIzMS4zLDc5LjggTDgzLjgsNzkuOCBDNjQsNzkuOCA0Ny45LDYzLjggNDcuOSw0NCBMNDcuOSwzOS4zIEM0Ny45LDE5LjUgNjQsMy40IDgzLjgsMy40IEwyMzEuMywzLjQgeiIgLz4KICAgICAgPHBhdGgKICAgICAgICBkPSJNMjc3LjEsMzA5IEMyOTYuOSwzMDkgMzEzLDMyNS4xIDMxMywzNDQuOSBMMzEzLDM0OS41IEMzMTMsMzY5LjMgMjk2LjksMzg1LjQgMjc3LjEsMzg1LjQgTDE5Ni4xLDM4NS40IEMxNzYuMywzODUuNCAxNjAuMiwzNjkuMyAxNjAuMiwzNDkuNSBMMTYwLjIsMzQ0LjkgQzE2MC4yLDMyNS4xIDE3Ni4zLDMwOSAxOTYuMSwzMDkgTDI3Ny4xLDMwOSB6IiAvPgogICAgPC9nPgogIDwvc3ZnPgo=
landingPage:
  image: theiacloud/theia-cloud-landing-page:0.10.0-next
  appDefinition: "theia-cloud-demo"
  additionalApps:
    coffee-editor:
      label: "Coffee Editor"
    cdt-cloud-demo:
      label: "CDT.cloud Blueprint"
```

`landingPage.appDefinition` specifies the default App Definition used on the landing page. `app.name` serves as the label for this application. If you have multiple app definitions, you can list them under `additionalApps`, using the app definition name as a key and providing a label for each.

Additionally, the SVG image displayed on the try-now page can be changed via the `app.logoData` property. This property expects a base64 encoded SVG image. For example, you can encode an SVG to base64 using `cat path/to/file.svg | base64 -w 0 -`.

If you want to make small changes to the wording, please check out the repository ([try now page](https://github.com/eclipsesource/theia-cloud/tree/main/node/try-now-page), [components](https://github.com/eclipsesource/theia-cloud/tree/main/node/try-now-page/src/components)).
Instructions for containerizing the web site can be foud [here](https://github.com/eclipsesource/theia-cloud/blob/main/documentation/Building.md).
The custom image can be specified as `landingPage.image`.

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

### Theia Cloud Common API

Easily build your own landing pages with the Theia Cloud Common API.
This guide provides an introductory overview.
*If you need more in-depth documentation, please visit our [support options]({{< relref "/support" >}}).*

Start by Integrating the API in your project. Add `@eclipse-theiacloud/common` to your project's dependencies:

```json
  "dependencies": {
    "@eclipse-theiacloud/common": "0.10.0-next",
    "keycloak-js": "20.0.3"
  },
```

The `TheiaCloud` namespace serves as the primary access point to the API, including sub-namespaces like `TheiaCloud.Session` and `TheiaCloud.Workspace` for session and workspace management.

A simple use case to start a session with a workspace and automatic redirects looks like this:

```ts
import { LaunchRequest, TheiaCloud } from '@eclipse-theiacloud/common';

const appId = 'asdfghjkl' // the app.id value used when installing the theia-cloud helm chart
const theiaCloudServiceURL = 'https://service.my-domain.io'; // the URL of the rest service
const appDefinition = 'theia-cloud-demo' // which app to start
const timeout = 5;
const userEmail = 'j.doe@theia-cloud.io';
const workspaceName = 'my-workspace';
TheiaCloud.launchAndRedirect(
    LaunchRequest.createWorkspace(theiaCloudServiceURL, appId, appDefinition, timeout, userEmail, workspaceName),
    { timeout: 60000, retries: 5, accessToken: token }
)
```

Please explore the `TheiaCloud` and its nested namespaces to learn about the API.

When you are using keycloak authentication, here is a small snippet how to get the accessToken and the user email for above request:

```ts
keycloakConfig = {
  url: 'https://keycloak.my-domain.io/',
  realm: 'TheiaCloud', // our getting started samples use TheiaCloud
  clientId: 'theia-cloud' // our getting started samples use theia-cloud
};
const keycloak = Keycloak(keycloakConfig);
keycloak
  .init({
    onLoad: 'check-sso',
    redirectUri: window.location.href,
    checkLoginIframe: false
  })
  .then(auth => {
    if (auth) {
      const parsedToken = keycloak.idTokenParsed;
      if (parsedToken) {
        // get tokens and email
        const userMail = parsedToken.email;
        setToken(keycloak.idToken);
        setEmail(userMail);
        setLogoutUrl(keycloak.createLogoutUrl());
      }
    }
  })
  .catch(() => {
    console.error('Authentication Failed');
  });
```
