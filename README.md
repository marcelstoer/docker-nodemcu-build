# Docker NodeMCU build
[![Docker Pulls](https://img.shields.io/docker/pulls/marcelstoer/nodemcu-build.svg)](https://hub.docker.com/r/marcelstoer/nodemcu-build/)
[![Docker Stars](https://img.shields.io/docker/stars/_/nodemcu-build.svg)](https://hub.docker.com/r/marcelstoer/nodemcu-build/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/marcelstoer/docker-nodemcu-build/blob/master/LICENSE)

Clone and edit the [NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware) locally on your platform. This image will take it from there and turn your code into a binary which you then can [flash to the ESP8266](https://learn.adafruit.com/building-and-running-micropython-on-the-esp8266/flash-firmware).

## Target audience
I see 3 types of NodeMCU developers:
- NodeMCU "application developers"
  
  They just need a ready-made firmware. I created a [cloud build service](http://frightanic.com/nodemcu-custom-build/index.php) with a nice UI and configuration options for them.

- Occasional NodeMCU hackers

  They don't need full control over the complete tool chain and also don't want to setup a Linux VM (if they're not on Linux anyway). **This image is _exactly_ for them!**

- NodeMCU firmware developers
  
  They commit or contribute to the project on GitHub and need their own full fledged [build environment with the complete tool chain](http://www.esp8266.com/wiki/doku.php?id=toolchain#how_to_setup_a_vm_to_host_your_toolchain). _They might also find this Docker image useful._

## Usage
### Install Docker
Follow the instructions at https://docs.docker.com/installation.

### Run this container with Docker
Clone the  [NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware) repository on your machine. Start Docker and change to your firmware directory (in the Docker console). Then run:

``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware marcelstoer/nodemcu-build``

Depending on the power of your system it takes anywhere between 1 and 3min until the compilation finishes. The first time you run this it takes longer because Docker needs to download the image and create a container.

### Flashing the built binary
There are several [tools to flash the firmware](https://learn.adafruit.com/building-and-running-micropython-on-the-esp8266/flash-firmware) to the ESP8266. If you were to use [esptool](https://github.com/themadinventor/esptool) (like I do) you'd run:

`esptool.py --port <USB-port-with-ESP8266> write_flash 0x00000 <NodeMCU-firmware-directory>/bin/nodemcu_[integer|float]_<Git-branch>.bin `

## Credits
Thanks to [Paul Sokolovsky](http://pfalcon-oe.blogspot.com/) who created and maintains [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk).

## Author
http://frightanic.com
