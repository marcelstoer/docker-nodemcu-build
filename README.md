# Docker NodeMCU build and LFS images
[![Docker Pulls](https://img.shields.io/docker/pulls/marcelstoer/nodemcu-build.svg)](https://hub.docker.com/r/marcelstoer/nodemcu-build/) [![Docker Stars](https://img.shields.io/docker/stars/marcelstoer/nodemcu-build.svg)](https://hub.docker.com/r/marcelstoer/nodemcu-build/) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/marcelstoer/docker-nodemcu-build/blob/master/LICENSE)

Clone and edit the [NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware) locally on your platform. This image will take it from there and turn your code into a binary which you then can [flash to the ESP8266](https://nodemcu.readthedocs.org/en/latest/en/flash/) or [the ESP32](https://nodemcu.readthedocs.io/en/dev-esp32/en/flash/).
It can also create LFS images from your Lua sources.

[中文文档请参阅 README-CN.md](README-CN.md)

* [Usage](#usage)
  * [Install Docker](#install-docker)
  * [Clone the NodeMCU firmware repository](#clone-the-nodemcu-firmware-repository)
  * [Build for ESP8266](#build-for-esp8266)
     * [Configure modules and features](#configure-modules-and-features)
     * [Build the firmware](#build-the-firmware)
     * [Create an LFS image for ESP8266](#create-an-lfs-image-for-esp8266)
  * [Build for ESP32](#build-for-esp32)
     * [Configure modules and features](#configure-modules-and-features-1)
     * [Build the firmware](#build-the-firmware-1)
  * [Options](#options)
  * [Note for Windows users](#note-for-windows-users)
* [Support](#support)
* [Credits](#credits)
* [Author](#author)


## Target audience
There seem to be three types of NodeMCU developers:

- NodeMCU "application developers"
  
  They just need a ready-made firmware. I created a [cloud build service](http://nodemcu-build.com/index.php) with a nice UI and configuration options for them.
  However, if they use [LFS](https://nodemcu.readthedocs.io/en/latest/en/lfs/) they might want to build their LFS images as an alternative to [Terry Ellison's online service](https://blog.ellisons.org.uk/article/nodemcu/a-lua-cross-compile-web-service/). **Then this image is right for them!**

- Occasional NodeMCU firmware hackers

  They don't need full control over the complete tool chain and don't want to setup a Linux VM with the build environment. **This image is _exactly_ for them!**

- NodeMCU firmware developers
  
  They commit or contribute to the project on GitHub and need their own full fledged [build environment with the complete tool chain](http://www.esp8266.com/wiki/doku.php?id=toolchain#how_to_setup_a_vm_to_host_your_toolchain). _They still might find this Docker image useful._
  
### :bangbang: Regular updates
If you have previously pulled this Docker image then you should update the image from time to time to pull in the latest bug fixes:

`docker pull marcelstoer/nodemcu-build`

# Usage

## Install Docker
Follow the instructions at [https://docs.docker.com/get-started/](https://docs.docker.com/get-started/).

## Clone the NodeMCU firmware repository
Docker runs on a VirtualBox VM which by default only shares the user directory from the underlying guest OS. On Windows that is `c:/Users/<user>` and on Mac it's `/Users/<user>`. Hence, you need to clone the  [NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware) repository to your *user directory*. If you want to place it outside the user directory you need to adjust the [VirtualBox VM sharing settings](http://stackoverflow.com/q/33934776/131929) accordingly.

`git clone --recurse-submodules https://github.com/nodemcu/nodemcu-firmware.git`

For ESP32 you would then switch to the `dev-esp32` branch and update the submodules:

```
git checkout dev-esp32
git submodule update --recursive
```

## Build for ESP8266

### Configure modules and features

**Note** The build script adds information about the options you set below to the NodeMCU boot message (dumped to console on application start).

To configure the modules to be built into the firmware edit `app/include/user_modules.h`.
Also consider turning on SSL or [LFS](https://nodemcu.readthedocs.io/en/dev/en/lfs/) in `app/include/user_config.h`. `#define LUA_NUMBER_INTEGRAL` in the same file gives you control over whether to build a firmware with floating point support or without. See the [NodeMCU documentation on build options](https://nodemcu.readthedocs.io/en/latest/en/build/#build-options) for other options and details.

The version information and build date are correctly set automatically unless you modify the parameters in `app/include/user_version.h`.

### Build the firmware
Start Docker and change to the NodeMCU firmware directory (in the Docker console). To build the firmware run:

``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware marcelstoer/nodemcu-build build``

Depending on the performance of your system it takes 1-3min until the compilation finishes. The first time you run this it takes longer because Docker needs to download the image and create a container.

#### Output
The firmware binary (integer or float) is created in the `bin` subfolder of your NodeMCU root directory. You will also find a mapfile in the `bin` folder with the same name as the firmware file but with a `.map` ending.

#### Flash the firmware
There are several [tools to flash the firmware](https://nodemcu.readthedocs.io/en/latest/en/flash/) to the ESP8266.

### Create an LFS image for ESP8266
Start Docker and change to the NodeMCU firmware directory (in the Docker console). To create the LFS image run:

``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware -v {PathToLuaSourceFolder}:/opt/lua marcelstoer/nodemcu-build lfs-image``

This will compile and store all Lua files in the given folder including subfolders.

#### Output
Depending on what type(s) of firmware you built this will create one or two LFS images in the root of your lua folder.

## Build for ESP32

NodeMCU for ESP32 is built on the [ESP-IDF](https://github.com/espressif/esp-idf) (Espressif IoT Development Framework). It uses a menu-driven user interface Kconfig to configure all firmware features and options. Hence, building NodeMCU for ESP32 is a two step process and you will launch the Docker container twice. First to start Kconfig, select all options and write the configuration file. Then to actually build the firmware.

### Configure modules and features

``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware marcelstoer/nodemcu-build configure-esp32``

This internally will run `make menuconfig` in the firmware directory. It will generate a `sdkconfig` file in the same.

### Build the firmware

``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware marcelstoer/nodemcu-build build``

That is the exact same command as for building for the ESP8266. It analyses the available files to figure out whether you checked out NodeMCU for ESP32 or ESP8266. The `build` command is thus a shortcut to using `build-esp32`.

The process will fail early with a meaningful error message if it does not find a `sdkconfig` file in the firmware directory.

## Options
You can pass the following optional parameters to the Docker build like so `docker run -e "<parameter>=value" -e ...`. 

- `IMAGE_NAME` The default firmware file names are `nodemcu_float|integer_<branch>_<timestamp>.bin` (no integer/float for ESP32). If you define an image name it replaces the `<branch>_<timestamp>` suffix and the full image names become `nodemcu_float|integer_<image_name>.bin`.
- `TZ` By default the Docker container will run in UTC timezone. Hence, the time in the timestamp of the default image name (see `IMAGE_NAME` option above) will not be same as your host system time - unless that is UTC as well of course. To fix this you can set the `TZ` parameter to any [valid timezone name](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) e.g. `-e TZ=Asia/Kolkata`.

`INTEGER_ONLY` and `FLOAT_ONLY` are **not supported anymore**. Please configure `LUA_NUMBER_INTEGRAL` in `app/include/user_config.h` as described above.

## Note for Windows users

(Docker on) Windows handles paths slightly differently. You need to specify the full path to the NodeMCU firmware directory in the command and you need to add an extra forward slash (`/`) to the Windows path. The command thus becomes (`c` equals C drive i.e. `c:`):

`docker run --rm -it -v //c/Users/<user>/<nodemcu-firmware>:/opt/nodemcu-firmware marcelstoer/nodemcu-build build`

If the Windows path contains spaces it would have to be wrapped in quotes as usual on Windows.

`docker run --rm -it -v "//c/Users/monster tune/<nodemcu-firmware>":/opt/nodemcu-firmware marcelstoer/nodemcu-build build`

If this Docker container hangs on sharing the drive (or starting) check whether the Windows service 'LanmanServer' is running. See [DockerBug #2196](https://github.com/docker/for-win/issues/2196) for details.

# Support
Ask a question on [StackOverflow](http://stackoverflow.com/) and assign the `nodemcu` and `docker` tags.

For bugs and improvement suggestions create an issue at [https://github.com/marcelstoer/docker-nodemcu-build/issues](https://github.com/marcelstoer/docker-nodemcu-build/issues).

# Credits
Thanks to [Paul Sokolovsky](http://pfalcon-oe.blogspot.com/) who created and maintains [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk).

A big "Thank You!" goes to [Gregor Hartmann](https://github.com/HHHartmann) who implemented LFS-support and removed the ill-designed `INTEGER_ONLY` / `FLOAT_ONLY` parameters for this image.

# Author
[https://frightanic.com](http://frightanic.com)
