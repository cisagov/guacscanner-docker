ARG VERSION=unspecified
ARG PY_VERSION=3.10.0

FROM python:${PY_VERSION}-slim-bullseye

ARG VERSION

# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
# Note: Additional labels are added by the build workflow.
LABEL org.opencontainers.image.authors="jeremy.frasier@cisa.dhs.gov"
LABEL org.opencontainers.image.vendor="Cybersecurity and Infrastructure Security Agency"

# Manually set up the virtual environment
ENV PY_VENV=/.venv
RUN python -m venv ${PY_VENV}
ENV PATH="${PY_VENV}/bin:$PATH"
RUN python -m pip install --upgrade pip

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
    useradd --system --uid ${CISA_UID} --gid ${CISA_GROUP} --comment "${CISA_USER} user" ${CISA_USER}

###
# Install everything we need
###

###
# Dependencies
#
# We need redis-tools so we can use redis-cli to communicate with
# redis.  wget is used inside of gather-domains.sh.
#
# Install dependencies are only needed for software installation and
# will be removed at the end of the build process.
###
ENV DEPS \
    libpq-dev
ENV INSTALL_DEPS \
    wget
# Temporary
ENV TEMP_DEPS \
    sudo \
    vim
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests --yes \
    ${DEPS} ${INSTALL_DEPS} ${TEMP_DEPS}
# Temporary
RUN echo ${CISA_USER}     "ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR ${CISA_HOME}

RUN wget -O sourcecode.tgz https://github.com/cisagov/guacscanner/archive/v${VERSION}.tar.gz && \
    tar xzf sourcecode.tgz --strip-components=1 && \
    python -m pip install --requirement requirements.txt && \
    rm sourcecode.tgz

###
# Remove install dependencies
###
RUN apt-get remove --yes ${INSTALL_DEPS} && \
    apt-get autoremove --yes

###
# Clean up aptitude cruft
###
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*


###
# Prepare to Run
###
USER ${CISA_USER}:${CISA_GROUP}
ENTRYPOINT ["guacscanner"]
CMD ["--log-level", "DEBUG"]
