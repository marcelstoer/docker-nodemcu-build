# Docker NodeMCU build and LFS images
[![Docker Pulls](https://img.shields.io/docker/pulls/marcelstoer/nodemcu-build.svg)](https://hub.docker.com/r/marcelstoer/nodemcu-build/) [![Docker Stars](https://img.shields.io/docker/stars/marcelstoer/nodemcu-build.svg)](https://hub.docker.com/r/marcelstoer/nodemcu-build/) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/marcelstoer/docker-nodemcu-build/blob/master/LICENSE)

Clone and edit the [NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware) locally on your platform. This image will take it from there and turn your code into a binary which you then can [flash to the ESP8266](http://nodemcu.readthedocs.org/en/dev/en/flash/).
It also can use the build to create LFS images from your Lua sources.

[中文文档请参阅 README-CN.md](README-CN.md)

## Target audience
I see 3 types of NodeMCU developers:
- NodeMCU "application developers"
  
  They just need a ready-made firmware. I created a [cloud build service](http://nodemcu-build.com/index.php) with a nice UI and configuration options for them.
  They also need the possibility to build LFS images. **This image is _exactly_ for them!**

- Occasional NodeMCU firmware hackers

  They don't need full control over the complete tool chain and don't want to setup a Linux VM with the build environment. **This image is _exactly_ for them!**

- NodeMCU firmware developers
  
  They commit or contribute to the project on GitHub and need their own full fledged [build environment with the complete tool chain](http://www.esp8266.com/wiki/doku.php?id=toolchain#how_to_setup_a_vm_to_host_your_toolchain). _They still might find this Docker image useful._

## Usage

### Install Docker
Follow the instructions at [https://docs.docker.com/get-started/](https://docs.docker.com/get-started/).

### Clone the NodeMCU firmware repository
Docker runs on a VirtualBox VM which by default only shares the user directory from the underlying guest OS. On Windows that is `c:/Users/<user>` and on Mac it's `/Users/<user>`. Hence, you need to clone the  [NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware) repository to your *user directory*. If you want to place it outside the user directory you need to adjust the [VirtualBox VM sharing settings](http://stackoverflow.com/q/33934776/131929) accordingly.

`git clone https://github.com/nodemcu/nodemcu-firmware.git`

### Run this image with Docker to create the firmware
Start Docker and change to the NodeMCU firmware directory (in the Docker console). To build the firmware run:

``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware marcelstoer/nodemcu-build build``

Depending on the performance of your system it takes 1-3min until the compilation finishes. The first time you run this it takes longer because Docker needs to download the image and create a container.

#### Output
The two firmware files (integer and float) are created in the `bin` sub folder of your NodeMCU root directory. You will also find a mapfile in the `bin` folder with the same name as the firmware file but with a `.map` ending.

#### Options
You can pass the following optional parameters to the Docker build like so `docker run -e "<parameter>=value" -e ...`. 

- `IMAGE_NAME` The default firmware file names are `nodemcu_float|integer_<branch>_<timestamp>.bin`. If you define an image name it replaces the `<branch>_<timestamp>` suffix and the full image names become `nodemcu_float|integer_<image_name>.bin`.
- `INTEGER_ONLY` Set this to 1 if you don't need NodeMCU with floating support, cuts the build time in half.
- `FLOAT_ONLY` Set this to 1 if you only need NodeMCU with floating support, cuts the build time in half.
- `TZ` By default the Docker container will run in UTC timezone. Hence, the time in the timestamp of the default image name (see `IMAGE_NAME` option above) will not be same as your host system time - unless that is UTC as well of course. To fix this you can set the `TZ` parameter to any [valid timezone name](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) e.g. `-e TZ=Asia/Kolkata`.

#### Flashing the built binary
There are several [tools to flash the firmware](http://nodemcu.readthedocs.org/en/dev/en/flash/) to the ESP8266. If you were to use [esptool](https://github.com/themadinventor/esptool) (like I do) you'd run:

`esptool.py --port <USB-port-with-ESP8266> write_flash 0x00000 <NodeMCU-firmware-directory>/bin/nodemcu_[integer|float]_<Git-branch>.bin `

### Run this image with Docker to create an LFS image
Start Docker and change to the NodeMCU firmware directory (in the Docker console). To create the LFS image run:

``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware marcelstoer/nodemcu-build -v {PathToLuaSourceFolder}:/opt/lua marcelstoer/nodemcu-build lfs-image``

This will compile and store all Lua files in the given folder including subdirs.

#### Output
Depending on what type(s) of firmware you built this will create one or two LFS images in the root of your lua folder.

### **Note for Windows users**

(Docker on) Windows handles paths slightly differently. You need to specify the full path to the NodeMCU firmware directory in the command and you need to add an extra forward slash (`/`) to the Windows path. The command thus becomes (`c` equals C drive i.e. `c:`):

`docker run --rm -it -v //c/Users/<user>/<nodemcu-firmware>:/opt/nodemcu-firmware marcelstoer/nodemcu-build build`

If the Windows path contains spaces it would have to be wrapped in quotes as usual on Windows.

`docker run --rm -it -v "//c/Users/monster tune/<nodemcu-firmware>":/opt/nodemcu-firmware marcelstoer/nodemcu-build build`

If your docker image hangs on sharing the drive (or starting) have a look if your service LanmanServer is running. Also see [DockerBug #2196](https://github.com/docker/for-win/issues/2196).

### :bangbang: If you have previously pulled this Docker image (e.g. with the command above) you should update the image from time to time to pull in the latest bug fixes:

`docker pull marcelstoer/nodemcu-build`

## Support
Don't leave comments on Docker Hub that are intended to be support requests. First, Docker Hub doesn't notify me when you write them, second I can't properly reply and third even if I could often it doesn't make much sense to keep them around forever and a day. Instead ask a question on [StackOverflow](http://stackoverflow.com/) and assign the `nodemcu` and `docker` tags.

For bugs and improvement suggestions create an issue at [https://github.com/marcelstoer/docker-nodemcu-build/issues](https://github.com/marcelstoer/docker-nodemcu-build/issues).

## Credits
Thanks to [Paul Sokolovsky](http://pfalcon-oe.blogspot.com/) who created and maintains [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk).

## Author
[https://frightanic.com](http://frightanic.com)
