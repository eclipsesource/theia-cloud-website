+++
fragment = "content"
weight = 100

title = "Add Your Application"

[sidebar]
  sticky = true
+++

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

## Containerize Your Theia Application

To launch your Theia application with Theia Cloud, it's essential to containerize your application first.
This tutorial provides a brief guide on achieving this.
Of course this needs to be tailored to your application's build process.

_For a practical example, refer to the [Theia IDE](https://github.com/eclipse-theia/theia-blueprint?tab=readme-ov-file#docker-build). It illustrates packaging a Theia-based application in a Dockerfile and creating desktop installers._

A staged build process is recommended, generally comprising at least two stages:

#### Build Stage

This stage is focused on compiling your application.
Aim for a comprehensive build rather than minimizing the image size.
Select a base image that facilitates an easy and maintainable build process without excessively optimizing.

#### Production Stage

Here, you transfer the build results from the first stage.
The objective is to install only the necessary software, keeping the image size minimal.
Choose a smaller base image, as it need not include the tools required for the build.
This stage should include only the dependencies essential for running your application.

#### Example Dockerfile

```dockerfile
# Stage 1: Builder stage
FROM node:20-bullseye as build-stage

# Install build dependencies
RUN apt-get update && apt-get install -y libxkbfile-dev libsecret-1-dev

# Set the working directory
WORKDIR /home/theia

# Copy the current directory contents to the container
COPY . .

# Run the build commands
RUN yarn --pure-lockfile && \
    yarn build:extensions && \
    yarn download:plugins && \
    yarn browser build && \
    yarn --production

# Stage 2: Production stage, using a slim image
FROM node:20-bullseye-slim as production-stage

# Create a non-root user with a fixed user id and setup the environment
RUN adduser --system --group --uid 200 theia && \
    chmod g+rw /home && \
    mkdir -p /home/theia && \
    chown -R theia:theia /home/theia
ENV HOME=/home/theia
WORKDIR /home/theia

# Copy the build output to the production environment
COPY --from=build-stage --chown=theia:theia /home/theia /home/theia

# Expose the default Theia port
EXPOSE 3000

# Use the non-root user
USER theia

# Set the working directory to the browser application
WORKDIR /home/theia/applications/browser

# Start the application
ENTRYPOINT ["node", "/home/theia/applications/browser/lib/backend/main.js"]
CMD ["--hostname=0.0.0.0"]
```

To create a `Dockerfile` for your application, use the above template as a starting point and customize it as needed.

Build your container image with:

```shell
docker build -t your-image:tag -f Dockerfile .
```

- `-t your-image:tag` specifies the image name and tag.
- `-f Dockerfile` indicates the Dockerfile path.
- `.` denotes the current directory context for the build.

Test your image with:

```shell
docker run -p=3000:3000 --rm your-image:tag
```

Adjust the port number as necessary.

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

## Enable Monitor (Optional)

Managing resources within your Kubernetes cluster is crucial for ensuring that users experience fast startup and response times.
However, it's equally important to consider the cost implications.
To address this, Theia Cloud provides an optional Monitor component.
This component assesses user activity within an IDE session.
Users are warned about potential session termination if they remain inactive.
Should inactivity continue beyond a specified timeout, the session is automatically stopped.

To leverage this functionality, you must integrate a specific component into your application, enabling communication with Theia Cloud.
There are two primary methods for incorporating this monitor.

### Theia Extension

The first method involves using a Theia extension, available directly from the npm registry.
To include it in your application, simply add `@eclipse-theiacloud/monitor-theia` to the `package.json` of your application, as shown below:

```json
"dependencies": {
  "@eclipse-theiacloud/monitor-theia": "next",
  "@theia/core": "1.43.1",
  "@theia/editor": "1.43.1",
  "@theia/editor-preview": "1.43.1",
  "@theia/electron": "1.43.1",
  "@theia/filesystem": "1.43.1",

```

For an example of how to implement this, consider our [test sample application](https://github.com/eclipsesource/theia-cloud/tree/main/demo/dockerfiles/demo-theia-monitor-theia).

### VS Code Extension

Alternatively, you may opt for the Theia Cloud Monitor VS Code extension.
This extension relies on the VSCode API for activity detection, which may not be as effective as the Theia Extension method.
Therefore, we recommend using the Theia Extension over the VS Code extension.
The `*.vsix` file for this extension can be downloaded from our GitHub Releases page.
For instance, for release 0.9.0, the extension is available [here](https://github.com/eclipsesource/theia-cloud/releases/download/0.9.0/theiacloud-monitor-0.9.0.vsix).

<img src="../../images/logo.png" alt="Theia Cloud Logo" width="100" style="display: block; margin: auto;" />

## Add an App Definition

After creating an image for your application, the next step is to author the App Definition.
This definition encapsulates all the universal information about your application, relevant to all users.
Use `kubectl apply -f your-appdefinition.yaml` to deploy this in the cluster.
Below is a starter template for the App Definition in YAML format.

```yaml
apiVersion: theia.cloud/v1beta9
kind: AppDefinition
metadata:
  name: my-theia-application
  namespace: my-namespace
spec:
  name: my-theia-application
  image: your-image:tag
  uid: 200
  port: 3000
  ingressname: theia-cloud-demo-ws-ingress
  minInstances: 0
  maxInstances: 10
  requestsMemory: 1000M
  requestsCpu: 100m
  limitsMemory: 1200M
  limitsCpu: "2"
  imagePullPolicy: IfNotPresent
  timeout: 240
  downlinkLimit: 30000
  uplinkLimit: 30000
  mountPath: /home/project/persisted
  monitor:
    port: 8081
    activityTracker:
      timeoutAfter: 30
      notifyAfter: 25
```

#### Mandatory Properties

- **`name`**: This is your application's identifier and is used to reference this App Definition. It is recommended to match `metadata.name` of the Kubernetes resource, meaning that valid characters include lowercase alphanumerics and '-'.

- **`image`**: Specify your container image.

- **`uid`**: The UNIX user identifier for the application launch user, typically specified in your Dockerfile. Avoid using the root user's identifier.
  **Tip:** We recommend setting a fixed user id via the `--uid` option of the `adduser` command.
  This guarantees a static id even when the base image or previously installed dependencies change.
  As the `adduser` command fails if the chosen user id is already taken, you know that your specified id is used when the docker build succeeds.

- **`port`**: The port on which Theia runs.

- **`ingressname`**: Defines the ingress resource to be patched for exposing new application sessions. Typically, this should match the `ingress.instanceName` used during the `theia-cloud` helm chart installation. For the default value, see [theia-cloud helm chart details](https://github.com/eclipsesource/theia-cloud-helm/tree/main/charts/theia.cloud).

- **`minInstances`**: Currently, this should be 0. Future versions may support pre-launching sessions for incoming users. _If you need this feature earlier, explore our [support options]({{< relref "/support" >}})._

- **`maxInstances`**: Sets the maximum number of application instances. Use a positive number for specific limits, or a negative number for no limit.

- **Resource Requests and Limits**: `requestsMemory`, `requestsCpu`, `limitsMemory`, and `limitsCpu` define the application's resource requirements, similar to Kubernetes resource definitions.

#### Optional Properties

- **`imagePullPolicy`**: Governs the image pull behavior, with options `"Always"`, `"IfNotPresent"`, or `"Never"`.

- **`timeout`**: Enables a hard shutdown after a specified duration (in minutes). Disable by omitting this property or using 0/negative values.

- **`downlinkLimit`** and **`uplinkLimit`**: Specify network speed limits in kilobits per second. Availability may vary based on the cluster and `operator.bandwidthLimiter` settings during `theia-cloud` helm chart installation.

- **`mountPath`**: The container path where workspace persistent storage is mounted.

- **Monitor Configuration**: `monitor.port`, `monitor.activityTracker.timeoutAfter`, and `monitor.activityTracker.notifyAfter` adjust Theia Cloud Monitor settings. Use the Theia application port for the Theia Cloud Extension, or `8081` for the VS Code extension. `notifyAfter` and `timeoutAfter` manage inactivity warnings and session terminations, respectively.
