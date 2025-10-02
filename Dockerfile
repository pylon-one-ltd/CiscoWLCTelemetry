# syntax=docker/dockerfile:1

# Use debian stable as our base
FROM debian:stable-slim

# Get target platform
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
RUN echo Building for platform: $TARGETPLATFORM

# Package info
LABEL org.opencontainers.image.source=https://github.com/pylon-one-ltd/CiscoWLCTelemetry
LABEL org.opencontainers.image.description="Cisco 9800 Telemetry gRPC"
LABEL org.opencontainers.image.maintainer="Pylon One <james@pylonone.com>"
LABEL org.opencontainers.image.version="1.0"

### Container Setup ###

# Install OS packages
RUN --mount=type=cache,target=/var/lib/apt/,sharing=locked \
    set -eux && \
    INSTALL_PKGS="bash \
            coreutils \
            python3 \
            pip \
            dnsutils \
            ca-certificates \
            vim \
            curl"  && \
    apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install ${INSTALL_PKGS} && \
    apt-get -y autoremove && \
    apt-get -y clean

# Create directories
RUN mkdir /var/lib/telemetry
WORKDIR /var/lib/telemetry

# Remove python 'Externally managed' flag
RUN rm /usr/lib/python3.13/EXTERNALLY-MANAGED

# Copy files
ADD proto /var/lib/telemetry/proto
COPY requirements.txt /var/lib/telemetry
COPY main.py /var/lib/telemetry

# Install Requirements
RUN pip3 install -r requirements.txt --break-system-packages

# Setup EntryPoint
ENTRYPOINT ["python3", "main.py"]