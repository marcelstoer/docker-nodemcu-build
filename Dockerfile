# see https://hub.docker.com/_/ubuntu/ for versions, should be the same as on Travis for NodeMCU CI
# 16.04 == xenial
FROM ubuntu:16.04
LABEL maintainer="marcelstoer"

# If you want to tinker with this Dockerfile on your machine do as follows:
# - git clone https://github.com/marcelstoer/docker-nodemcu-build
# - cd docker-nodemcu-build
# - vim Dockerfile
# - docker build -t docker-nodemcu-build .
# - cd <nodemcu-firmware>
# - docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware docker-nodemcu-build build

# Lint the final file with https://hadolint.github.io/hadolint/

# Deleting apt-get lists is done at the very end
# hadolint ignore=DL3009
RUN apt-get update && apt-get install -y --no-install-recommends wget unzip git make python-serial srecord bc xz-utils gcc ccache tzdata vim-tiny

# additionally required for ESP32 builds as per https://nodemcu.readthedocs.io/en/dev-esp32/build/#ubuntu
RUN apt-get install -y --no-install-recommends gperf python-pip python-dev flex bison build-essential libssl-dev libffi-dev libncurses5-dev libncursesw5-dev libreadline-dev

RUN pip install --upgrade pip

RUN mkdir /opt/nodemcu-firmware
WORKDIR /opt/nodemcu-firmware

RUN rm -rf /root
RUN ln -s /tmp /root
ENV PATH="/opt:${PATH}"

COPY cmd.sh /opt/
COPY read.me /opt/
COPY build /opt/
COPY build-esp32 /opt/
COPY build-esp8266 /opt/
COPY configure-esp32 /opt/
COPY lfs-image /opt/

# Release some space...
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

CMD ["/opt/cmd.sh"]
