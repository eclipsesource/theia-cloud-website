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

*For a practical example, refer to the [Theia IDE](https://github.com/eclipse-theia/theia-blueprint?tab=readme-ov-file#docker-build). It illustrates packaging a Theia-based application in a Dockerfile and creating desktop installers.*

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

# Create a non-root user and setup the environment
RUN adduser --system --group theia && \
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

* `-t your-image:tag` specifies the image name and tag.
* `-f Dockerfile` indicates the Dockerfile path.
* `.` denotes the current directory context for the build.

Test your image with:

```shell
docker run -p=3000:3000 --rm your-image:tag
```

Adjust the port number as necessary.
