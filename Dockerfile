ARG VERSION=unspecified
ARG PY_VERSION=3.10.7

FROM python:${PY_VERSION}-slim-bullseye AS compile-stage

ARG VERSION

###
# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
#
# Note: Additional labels are added by the build workflow.
###
LABEL org.opencontainers.image.authors="vm-fusion-dev-group@trio.dhs.gov"
LABEL org.opencontainers.image.vendor="Cybersecurity and Infrastructure Security Agency"

###
# Unprivileged user setup variables
###
ARG CISA_UID=421
ARG CISA_GID=${CISA_UID}
ARG CISA_USER="cisa"
ENV CISA_GROUP=${CISA_USER}
ENV CISA_HOME="/home/${CISA_USER}"

###
# Upgrade the system
###
RUN apt-get update --quiet --quiet \
    && apt-get upgrade --quiet --quiet

###
# Create unprivileged user
###
RUN groupadd --system --gid ${CISA_GID} ${CISA_GROUP} \
    && useradd --system --uid ${CISA_UID} --gid ${CISA_GROUP} --comment "${CISA_USER} user" ${CISA_USER}

###
# Install everything we need
#
# Install dependencies are only needed for software installation and
# will not be included in the final Docker image.
###
ENV DEPS \
    libpq-dev=13.11-0+deb11u1
# I'd like to pin the version of wget to keep the build reproducible,
# but it's tricky.
#
# I need to use version 1.21-1+b1 of wget for amd64 and version 1.21-1
# of wget otherwise.
# https://packages.debian.org/bullseye/wget
#
# I presume the solution is to somehow make use of this jazz:
# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope)
#
# But I don't see a way to do ternary logic with ENVs in a Dockerfile.
#
# Here is a post from StackOverflow where someone asks a similar
# question:
# https://stackoverflow.com/questions/67596193/building-a-multi-architecture-docker-image-but-dockerfile-requires-different-pa
ENV INSTALL_DEPS \
    wget
RUN apt-get install --quiet --quiet --yes \
    --no-install-recommends --no-install-suggests \
    $DEPS $INSTALL_DEPS

###
# Make sure pip, setuptools, and wheel are the latest versions
#
# Note that we use pip3 --no-cache-dir to avoid writing to a local
# cache.  This results in a smaller final image, at the cost of
# slightly longer install times.
###
RUN pip3 install --no-cache-dir --upgrade \
    pip \
    setuptools \
    wheel

###
# Perform remaining steps as the unprivileged user, from the
# unprivileged user's home directory
###
USER ${CISA_USER}:${CISA_GROUP}
WORKDIR ${CISA_HOME}

###
# Manually set up the virtual environment
###
ENV PY_VENV=${CISA_HOME}/.venv
RUN python3 -m venv ${PY_VENV}
ENV PATH="${PY_VENV}/bin:$PATH"
# Install/upgrade core Python dependencies
RUN python3 -m pip install --no-cache-dir --upgrade \
    pip==21.3.1 \
    setuptools==58.5.3 \
    wheel==0.37.0

# Download and install guacscanner
RUN python3 -m pip install --no-cache-dir \
    https://github.com/cisagov/guacscanner/archive/v${VERSION}.tar.gz


FROM python:${PY_VERSION}-slim-bullseye AS build-stage

###
# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
#
# Note: Additional labels are added by the build workflow.
###
LABEL org.opencontainers.image.authors="vm-fusion-dev-group@trio.dhs.gov"
LABEL org.opencontainers.image.vendor="Cybersecurity and Infrastructure Security Agency"

###
# Unprivileged user setup variables
###
ARG CISA_UID=421
ARG CISA_GID=${CISA_UID}
ARG CISA_USER="cisa"
ENV CISA_GROUP=${CISA_USER}
ENV CISA_HOME="/home/${CISA_USER}"

###
# Upgrade the system
###
RUN apt-get update --quiet --quiet \
    && apt-get upgrade --quiet --quiet

###
# Create unprivileged user
###
RUN groupadd --system --gid ${CISA_GID} ${CISA_GROUP} \
    && useradd --system --uid ${CISA_UID} --gid ${CISA_GROUP} --comment "${CISA_USER} user" ${CISA_USER}

###
# Install everything we need
###
ENV DEPS \
    libpq-dev=13.11-0+deb11u1
# Note that we clean up aptitude cruft after installing dependencies.
# This must be done in one fell swoop to actually reduce the size of
# the resulting Docker image:
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#minimize-the-number-of-layers
RUN apt-get install --quiet --quiet --yes \
    --no-install-recommends --no-install-suggests \
    $DEPS \
    && apt-get clean \
    && rm --recursive --force /var/lib/apt/lists/*

# Manually set up the virtual environment, copying the venv over from
# the compile stage
ENV PY_VENV=${CISA_HOME}/.venv
COPY --from=compile-stage ${CISA_HOME} ${CISA_HOME}/
ENV PATH="${PY_VENV}/bin:$PATH"

###
# Prepare to run
###
USER ${CISA_USER}:${CISA_GROUP}
WORKDIR ${CISA_HOME}
ENTRYPOINT ["guacscanner"]
