# guacscanner-docker 💀🐳 #

[![GitHub Build Status](https://github.com/cisagov/guacscanner-docker/workflows/build/badge.svg)](https://github.com/cisagov/guacscanner-docker/actions/workflows/build.yml)
[![CodeQL](https://github.com/cisagov/guacscanner-docker/workflows/CodeQL/badge.svg)](https://github.com/cisagov/guacscanner-docker/actions/workflows/codeql-analysis.yml)
[![Known Vulnerabilities](https://snyk.io/test/github/cisagov/guacscanner-docker/badge.svg)](https://snyk.io/test/github/cisagov/guacscanner-docker)

## Docker Image ##

[![Docker Pulls](https://img.shields.io/docker/pulls/cisagov/guacscanner)](https://hub.docker.com/r/cisagov/guacscanner)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/cisagov/guacscanner)](https://hub.docker.com/r/cisagov/guacscanner)
[![Platforms](https://img.shields.io/badge/platforms-amd64%20%7C%20arm%2Fv6%20%7C%20arm%2Fv7%20%7C%20arm64%20%7C%20ppc64le%20%7C%20s390x-blue)](https://hub.docker.com/r/cisagov/guacscanner-docker/tags)

This project [Dockerizes](https://docker.com)
[cisagov/guacscanner](https://github.com/cisagov/guacscanner), and the
resulting Docker container is intended to run as a part of
[cisagov/guacamole-composition](https://github.com/cisagov/guacamole-composition),
although it could - probably uselessly - run in a [Docker
composition](https://docs.docker.com/compose/) alongside only the
[official PostgreSQL Docker image](https://hub.docker.com/_/postgres).

## Running ##

### Running with Docker ###

To run the `cisagov/guacscanner` image via Docker:

```console
docker run cisagov/guacscanner:1.1.13
```

### Running with Docker Compose ###

See
[cisagov/guacamole-composition](https://github.com/cisagov/guacamole-composition))
for an example of how to create a `docker-compose.yml` file to use
[Docker Compose](https://docs.docker.com/compose/).  With a
`docker-compose.yml` file in hand, one need only start the container
and detach:

```console
docker compose up --detach
```

## Using secrets with your container ##

This container also supports passing sensitive values via [Docker
secrets](https://docs.docker.com/engine/swarm/secrets/).  Passing sensitive
values like your credentials can be more secure using secrets than using
environment variables.  See the
[secrets](#secrets) section below for a table of all supported secret files.

Again, see
[cisagov/guacamole-composition](https://github.com/cisagov/guacamole-composition))
for an example of how to create a `docker-compose.yml` file that uses
Docker secrets.

## Updating your container ##

### Docker Compose ###

1. Pull the new image from Docker Hub:

    ```console
    docker compose pull
    ```

1. Recreate the running container by following the [previous
   instructions](#running-with-docker-compose):

    ```console
    docker compose up --detach
    ```

### Docker ###

1. Stop the running container:

    ```console
    docker stop <container_id>
    ```

1. Pull the new image:

    ```console
    docker pull cisagov/guacscanner:1.1.13
    ```

1. Recreate and run the container by following the [previous
   instructions](#running-with-docker).

## Image tags ##

The images of this container are tagged with [semantic
versions](https://semver.org) of the underlying example project that
they containerize.  It is recommended that most users use a version
tag (e.g. `:1.1.13`).

| Image:tag | Description |
|-----------|-------------|
|`cisagov/guacscanner:1.1.13`| An exact release version. |
|`cisagov/guacscanner:1.1`| The most recent release matching the major and minor version numbers. |
|`cisagov/guacscanner:1`| The most recent release matching the major version number. |
|`cisagov/guacscanner:edge` | The most recent image built from a merge into the `develop` branch of this repository. |
|`cisagov/guacscanner:nightly` | A nightly build of the `develop` branch of this repository. |
|`cisagov/guacscanner:latest`| The most recent release image pushed to a container registry.  Pulling an image using the `:latest` tag [should be avoided.](https://vsupalov.com/docker-latest-tag/) |

See the [tags tab](https://hub.docker.com/r/cisagov/guacscanner/tags)
on Docker Hub for a list of all the supported tags.

## Volumes ##

There are no volumes.

<!--
| Mount point | Purpose        |
|-------------|----------------|
| `/var/log`  |  Log storage   |
-->

## Ports ##

No ports are exposed by this container.

<!--
| Port | Purpose        |
|------|----------------|
| 8080 | Example only; nothing is actually listening on the port |
-->

<!--
The sample [Docker composition](docker-compose.yml) publishes the
exposed port at 8080.
-->

## Environment variables ##

### Required ###

There are no required environment variables.

<!--
| Name  | Purpose | Default |
|-------|---------|---------|
| `REQUIRED_VARIABLE` | Describe its purpose. | `null` |
-->

### Optional ###

There are no optional environment variables.

<!--
| Name  | Purpose | Default |
|-------|---------|---------|
| `ECHO_MESSAGE` | Sets the message echoed by this container.  | `Hello World from Dockerfile` |
-->

## Secrets ##

| Filename     | Purpose |
|--------------|---------|
| postgres_username | Text file containing the username of the `postgres` user used by the `guacamole` container. |
| postgres_password | Text file containing the password of the `postgres` user used by the `guacamole` container. |
| private_ssh_key | Text file containing the private SSH key to use for SFTP file transfer in Guacamole. |
| rdp_username | Text file containing the username for Guacamole to use when connecting to an instance via RDP. |
| rdp_password | Text file containing the password for Guacamole to use when connecting to an instance via RDP. |
| vnc_username | Text file containing the username for Guacamole to use when connecting to an instance via VNC. |
| vnc_password | Text file containing the password for Guacamole to use when connecting to an instance via VNC. |
| windows_sftp_base | Text file containing the base path for the SFTP directories that Guacamole will use when connecting to a Windows instance via VNC. |

## Building from source ##

Build the image locally using this git repository as the [build context](https://docs.docker.com/engine/reference/commandline/build/#git-repositories):

```console
docker build \
  --build-arg VERSION=1.1.13 \
  --tag cisagov/guacscanner:1.1.13 \
  https://github.com/cisagov/guacscanner.git#develop
```

## Cross-platform builds ##

To create images that are compatible with other platforms, you can use the
[`buildx`](https://docs.docker.com/buildx/working-with-buildx/) feature of
Docker:

1. Copy the project to your machine using the `Code` button above
   or the command line:

    ```console
    git clone https://github.com/cisagov/guacscanner.git
    cd guacscanner
    ```

1. Create the `Dockerfile-x` file with `buildx` platform support:

    ```console
    ./buildx-dockerfile.sh
    ```

1. Build the image using `buildx`:

    ```console
    docker buildx build \
      --file Dockerfile-x \
      --platform linux/amd64 \
      --build-arg VERSION=1.1.13 \
      --output type=docker \
      --tag cisagov/guacscanner:1.1.13 .
    ```

## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
