# see https://hub.docker.com/_/ubuntu/ for versions, should be the same as on Travis for NodeMCU CI
# 14.04 == trusty
FROM ubuntu:14.04
MAINTAINER marcelstoer

# If you want to tinker with this Dockerfile on your machine do as follows:
# - git clone https://github.com/marcelstoer/docker-nodemcu-build
# - vim docker-nodemcu-build/Dockerfile
# - docker build -t docker-nodemcu-build docker-nodemcu-build
# - cd <nodemcu-firmware>
# - docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware docker-nodemcu-build build

RUN apt-get update && apt-get install -y wget unzip git make python-serial srecord bc xz-utils gcc ccache tzdata

# additionally required for ESP32 builds
RUN apt-get update && apt-get install -y gperf python-pip python-dev flex bison build-essential libssl-dev libffi-dev libncurses5-dev libncursesw5-dev
RUN pip install --upgrade pip &&\
    pip install urllib3[secure] &&\
    pip install --upgrade  setuptools &&\
    pip install cryptography
# Ubuntu trusty ships with make 3.8.x but ESP32 requires >= 4.0
RUN wget https://mirrors.edge.kernel.org/ubuntu/pool/main/m/make-dfsg/make_4.1-6_amd64.deb &&\
    sudo dpkg -i make_4.1-6_amd64.deb

# Release some space...
RUN rm -rf /var/lib/apt/lists/*
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

CMD /opt/cmd.sh
