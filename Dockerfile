FROM ubuntu:20.04
LABEL AUTHOR = mio <moi@lris.net>

# Enable source repositories so we can use `apt build-dep` to get all the
# build dependencies for Python 2.7 and 3.5+.
RUN sed -i -- 's/#deb-src/deb-src/g' /etc/apt/sources.list && \
    sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list


# Set Debian front-end to non-interactive so that apt doesn't ask for
# prompts later.
ENV  DEBIAN_FRONTEND=noninteractive

RUN useradd pythoner --create-home && \
    # Create and change permissions for builds directory.
    mkdir /builds && \
    chown pythoner /builds && \
    export LC_ALL=C.UTF-8 && export LANG=C.UTF-8

RUN apt-get update \
  && apt-get install -y build-essential git libexpat1-dev libssl-dev zlib1g-dev \
  libncurses5-dev libbz2-dev liblzma-dev \
  libsqlite3-dev libffi-dev tcl-dev linux-headers-generic libgdbm-dev \
  libreadline-dev tk tk-dev \
  gdb

# # Use a new layer here so that these static changes are cached from above
# # layer.  Update Xenial and install the build-deps.
# RUN apt -qq -o=Dpkg::Use-Pty=0 update && \
#     apt -qq -o=Dpkg::Use-Pty=0 -y dist-upgrade && \
#     # Use python3.8 build-deps for Ubuntu 20.04
#     apt -qq -o=Dpkg::Use-Pty=0 build-dep -y python3.8 && \
#     apt -qq -o=Dpkg::Use-Pty=0 install -y python3-pip wget unzip git && \
#     # Remove apt's lists to make the image smaller.
#     rm -rf /var/lib/apt/lists/*
# # Get and install all versions of Python.
# RUN ./usr/local/bin/get_versions.py && ./usr/local/bin/get-pythons.sh > /dev/null
#     # Install some other useful tools for test environments.
#     # Require a newer version of six until an issue with
#     # pip dependency resolution when required package versions conflict is resolved.
#     # See: https://github.com/pypa/virtualenv/issues/1551 for context.
# RUN pip3 install mypy codecov tox "six>=1.14.0"
# RUN mv versions.txt /usr/local/bin/versions.txt

# Switch to runner user and set the workdir.
USER pythoner
WORKDIR /home/pythoner

COPY --chown=pythoner ./ /home/pythoner/cpython

# RUN sudo chown pythoner /home/pythoner/cpython