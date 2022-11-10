FROM mcr.microsoft.com/devcontainers/base:ubuntu

# VARIANT can be either 'hugo' for the standard version or 'hugo_extended' for the extended version.
ARG VARIANT=hugo_extended
# VERSION can be either 'latest' or a specific version number
ARG VERSION=latest

# RUN apt-get update && apt-get install -y ca-certificates openssl git curl && \
#     rm -rf /var/lib/apt/lists/*

# Download Hugo
ADD bootstrap.sh /bootstrap.sh
RUN /bootstrap.sh $VARIANT $VERSION