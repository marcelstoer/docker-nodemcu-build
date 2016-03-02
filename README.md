# Docker NodeMCU build
[![Docker Pulls](https://img.shields.io/docker/pulls/marcelstoer/nodemcu-build.svg)](https://hub.docker.com/r/marcelstoer/nodemcu-build/) [![Docker Stars](https://img.shields.io/docker/stars/marcelstoer/nodemcu-build.svg)](https://hub.docker.com/r/marcelstoer/nodemcu-build/) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/marcelstoer/docker-nodemcu-build/blob/master/LICENSE)

Clone and edit the [NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware) locally on your platform. This image will take it from there and turn your code into a binary which you then can [flash to the ESP8266](http://nodemcu.readthedocs.org/en/dev/en/flash/).

## Target audience
I see 3 types of NodeMCU developers:
- NodeMCU "application developers"
  
  They just need a ready-made firmware. I created a [cloud build service](http://nodemcu-build.com/index.php) with a nice UI and configuration options for them.

- Occasional NodeMCU firmware hackers

  They don't need full control over the complete tool chain and don't want to setup a Linux VM with the build environment. **This image is _exactly_ for them!**

- NodeMCU firmware developers
  
  They commit or contribute to the project on GitHub and need their own full fledged [build environment with the complete tool chain](http://www.esp8266.com/wiki/doku.php?id=toolchain#how_to_setup_a_vm_to_host_your_toolchain). _They still might find this Docker image useful._

## Usage
### Install Docker
Follow the instructions at https://docs.docker.com/ → 'Get Started' (orange button top right).

### Run this container with Docker
Clone the  [NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware) repository on your machine. Start Docker and change to your firmware directory (in the Docker console). Then run:

``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware marcelstoer/nodemcu-build``

Depending on the power of your system it takes anywhere between 1 and 3min until the compilation finishes. The first time you run this it takes longer because Docker needs to download the image and create a container.

**Note for Windows users**

(Docker on) Windows handles paths slightly differently. You need to specify the full path to your firmware directory in the command and you need to add an extra forward slash (`/`) in front of the two paths. The command thus becomes (`c` equals C drive i.e. `c:`):

`docker run --rm -it -v //c/<nodemcu-firmware-directory>://opt/nodemcu-firmware marcelstoer/nodemcu-build`

#### Output
The two firmware files (integer and float) are created in the `bin` sub folder of your NodeMCU root directory. You will also find a mapfile in the `bin` folder with the same name as the firmware file but with a `.map` ending.

#### Options
You can pass the following optional parameters to the Docker build like so `docker run -e "<parameter>=value" -e ...`. 

- `IMAGE_NAME` The default firmware file names are `nodemcu_float|integer_<branch>_<timestamp>.bin`. If you define an image name it replaces the `<branch>_<timestamp>` suffix and the full image names become `nodemcu_float|integer_<image_name>.bin`.
- `INTEGER_ONLY` Set this to 1 if you don't need NodeMCU with floating support, cuts the build time in half.
- `FLOAT_ONLY` Set this to 1 if you only need NodeMCU with floating support, cuts the build time in half.

### Flashing the built binary
There are several [tools to flash the firmware](http://nodemcu.readthedocs.org/en/dev/en/flash/) to the ESP8266. If you were to use [esptool](https://github.com/themadinventor/esptool) (like I do) you'd run:

`esptool.py --port <USB-port-with-ESP8266> write_flash 0x00000 <NodeMCU-firmware-directory>/bin/nodemcu_[integer|float]_<Git-branch>.bin `

## Credits
Thanks to [Paul Sokolovsky](http://pfalcon-oe.blogspot.com/) who created and maintains [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk).

## Author
[http://frightanic.com](http://frightanic.com)
