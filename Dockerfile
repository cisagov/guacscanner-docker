ARG VERSION=unspecified
ARG PY_VERSION=3.10.0

FROM python:${PY_VERSION}-slim-bullseye AS compile-stage

ARG VERSION

# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
# Note: Additional labels are added by the build workflow.
LABEL org.opencontainers.image.authors="jeremy.frasier@cisa.dhs.gov"
LABEL org.opencontainers.image.vendor="Cybersecurity and Infrastructure Security Agency"

###
# Install everything we need
###

###
# Dependencies
#
# Install dependencies are only needed for software installation and
# will not be included in the final Docker image.
###
ENV DEPS \
    libpq-dev
ENV INSTALL_DEPS \
    wget
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests --yes \
    ${DEPS} ${INSTALL_DEPS}

###
# Setup the unprivileged user and its home directory
###
ARG CISA_GID=421
ARG CISA_UID=${CISA_GID}
ENV CISA_USER="cisa"
ENV CISA_GROUP=${CISA_USER}
ENV CISA_HOME="/home/cisa"

###
# Create unprivileged user
###
RUN groupadd --system --gid ${CISA_GID} ${CISA_GROUP} && \
    useradd --system --create-home \
    --uid ${CISA_UID} --gid ${CISA_GROUP} \
    --comment "${CISA_USER} user" ${CISA_USER}

# Perform remaining steps as the unprivileged user, from the
# unprivileged user's home directory
USER ${CISA_USER}:${CISA_GROUP}
WORKDIR ${CISA_HOME}

# Manually set up the virtual environment
ENV PY_VENV=${CISA_HOME}/.venv
RUN python -m venv ${PY_VENV}
ENV PATH="${PY_VENV}/bin:$PATH"
# Install/upgrade core Python dependencies
RUN python -m pip install --upgrade pip setuptools wheel

# Download and install guacscanner
RUN wget -O sourcecode.tgz \
    https://github.com/cisagov/guacscanner/archive/v${VERSION}.tar.gz && \
    tar xzf sourcecode.tgz --strip-components=1 && \
    python -m pip install --requirement requirements.txt && \
    rm sourcecode.tgz

FROM python:${PY_VERSION}-slim-bullseye AS build-stage

# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
# Note: Additional labels are added by the build workflow.
LABEL org.opencontainers.image.authors="jeremy.frasier@cisa.dhs.gov"
LABEL org.opencontainers.image.vendor="Cybersecurity and Infrastructure Security Agency"

###
# Dependencies
###
ENV DEPS \
    libpq-dev
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests --yes \
    ${DEPS}

# Clean up aptitude cruft
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

###
# Setup the unprivileged user and its home directory
###
ARG CISA_GID=421
ARG CISA_UID=${CISA_GID}
ENV CISA_USER="cisa"
ENV CISA_GROUP=${CISA_USER}
ENV CISA_HOME="/home/cisa"

###
# Create unprivileged user
###
RUN groupadd --system --gid ${CISA_GID} ${CISA_GROUP} && \
    useradd --system --create-home \
    --uid ${CISA_UID} --gid ${CISA_GROUP} \
    --comment "${CISA_USER} user" ${CISA_USER}

# Manually set up the virtual environment, copying the venv over from
# the compile stage
ENV PY_VENV=${CISA_HOME}/.venv
COPY --from=compile-stage ${CISA_HOME} ${CISA_HOME}/
ENV PATH="${PY_VENV}/bin:$PATH"

###
# Prepare to Run
###
USER ${CISA_USER}:${CISA_GROUP}
WORKDIR ${CISA_HOME}
ENTRYPOINT ["guacscanner"]
