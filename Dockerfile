# see https://hub.docker.com/_/ubuntu/ for versions, should be the same as on Travis for NodeMCU CI
# 14.04 == trusty
FROM ubuntu:14.04
MAINTAINER marcelstoer

# If you want to tinker with this Dockerfile on your machine do as follows:
# - git clone https://github.com/marcelstoer/docker-nodemcu-build
# - vim docker-nodemcu-build/Dockerfile
# - docker build -t docker-nodemcu-build docker-nodemcu-build
# - cd <nodemcu-firmware>
# - docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware docker-nodemcu-build

RUN apt-get update && apt-get install -y wget unzip git make python-serial srecord bc xz-utils gcc ccache tzdata
# Release some space...
RUN rm -rf /var/lib/apt/lists/*
RUN mkdir /opt/nodemcu-firmware
WORKDIR /opt/nodemcu-firmware

RUN rm -rf /root
RUN ln -s /tmp /root

COPY cmd.sh /opt/

CMD /opt/cmd.sh
