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
  * [Notes for Windows users](#notes-for-windows-users)
  * [Notes for macOS users](#notes-for-macos-users)
* [Updating NodeMCU](#updating-nodemcu)
  * [Starting over](#starting-over)
  * [Attempt to preserve your changes](#attempt-to-preserve-your-changes)
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
All outputs will be created in the `bin` subfolder of your NodeMCU repository's root directory. They will be:

* `nodemcu_${BUILD_TYPE}_${IMAGE_NAME}.bin` is the combined firmware image
  you can flash.
  `BUILD_TYPE` is `integer` or `float`.
  For `IMAGE_NAME`, see the [Options](#options) chapter below.
  * Almost same but with `.map` ending, a mapfile will be saved that contains the relative offsets of functions.
* `0x00000.bin` will contain just the firmware.
* `0x10000.bin` will contain the SPIFFS.

#### Flash the firmware
There are several [tools to flash the firmware](https://nodemcu.readthedocs.io/en/latest/en/flash/) to the ESP8266.

### Create an LFS image for ESP8266
Start Docker and change to the NodeMCU firmware directory (in the Docker console). To create the LFS image run:

``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware -v {PathToLuaSourceFolder}:/opt/lua marcelstoer/nodemcu-build lfs-image``

This will compile and store all Lua files in the given folder including subfolders.

To only add specific files you can prepare a file containing the files to add and give them as paramater.

``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware -v {PathToLuaSourceFolder}:/opt/lua marcelstoer/nodemcu-build lfs-image final/files.lst``

Assume the following content of files.lst:
```
lib/*.lua    main.lua
../baseProject/*.lua
```
NOTE: use linux path separator '/' instead of Windows type '\'.
Basically this is just an ``ls`` expression as long as it contains no spaces and other shell escapable characters.

Assume the following files inside ``{PathToLuaSourceFolder}`` which is mounted as ``/opt/lua``
```
baseProject/base.lua
baseProject/lib/baseLib.lua
final/files.lst
final/lib/lib1.lua
final/main.lua
main.lua
```
this would add the following files
```
baseProject/base.lua
final/lib/lib1.lua
final/main.lua
```

#### Output
Depending on what type(s) of firmware you built this will create one or two LFS images in the root of your Lua folder.

## Build for ESP32

NodeMCU for ESP32 is built on the [ESP-IDF](https://github.com/espressif/esp-idf) (Espressif IoT Development Framework). It uses a menu-driven user interface Kconfig to configure all firmware features and options. Hence, building NodeMCU for ESP32 is a two step process and you will launch the Docker container twice. First to start Kconfig, select all options and write the configuration file. Then to actually build the firmware.

**Note** make sure you have got the Git submodules loaded as [described above](#clone-the-nodemcu-firmware-repository).

### Configure modules and features

``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware marcelstoer/nodemcu-build configure-esp32``

This internally will run `make menuconfig` in the firmware directory. It will generate a `sdkconfig` file in the same.

### Build the firmware

``docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware marcelstoer/nodemcu-build build``

That is the exact same command as for building for the ESP8266. It analyses the available files to figure out whether you checked out NodeMCU for ESP32 or ESP8266. The `build` command is thus a shortcut to using `build-esp32`.

The process will fail early with a meaningful error message if it does not find a `sdkconfig` file in the firmware directory.

### Output
All outputs will be created in the `bin` subfolder of your NodeMCU repository's root directory. They will be:

* `nodemcu_${IMAGE_NAME}.bin` will be the firmware image.
    For `IMAGE_NAME`, see the [Options](#options) chapter below.

## Options
You can pass the following optional parameters to the Docker build like so `docker run -e "<parameter>=value" -e ...`.

- `BUILD_MAKE_TARGETS` A space-separated list of custom make targets to build, instead of the default ones.
- `IMAGE_NAME` can be set to save the output files (see your platform's "Output" section for above) with fixed names. If it is not set or empty, the branch name and a timestamp will be used.
- `TZ` By default the Docker container will run in UTC timezone. Hence, the time in the timestamp of the default image name (see `IMAGE_NAME` option above) will not be same as your host system time - unless that is UTC as well of course. To fix this you can set the `TZ` parameter to any [valid timezone name](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) e.g. `-e TZ=Asia/Kolkata`.

`INTEGER_ONLY` and `FLOAT_ONLY` are **not supported anymore**. Please configure `LUA_NUMBER_INTEGRAL` in `app/include/user_config.h` as described above.

## Notes for Windows users

(Docker on) Windows handles paths slightly differently. You need to specify the full path to the NodeMCU firmware directory in the command:

`docker run --rm -it -v c:/Users/<user>/<nodemcu-firmware>:/opt/nodemcu-firmware marcelstoer/nodemcu-build build`

If the Windows path contains spaces it would have to be wrapped in quotes as usual on Windows.

`docker run --rm -it -v "c:/Users/monster tune/<nodemcu-firmware>":/opt/nodemcu-firmware marcelstoer/nodemcu-build build`

If this Docker container hangs on sharing the drive (or starting) check whether the Windows service 'LanmanServer' is running. See [DockerBug #2196](https://github.com/docker/for-win/issues/2196) for details.

## Notes for macOS users

[Docker for Mac is slow](https://markshust.com/2018/01/30/performance-tuning-docker-mac/). Period. However, much of the I/O-related latency can be significantly reduced with tuned volume mounts. Docker for Mac 17.04 introduced a "delegated" flag to avoid keeping host file system and container file system in perfect sync all the time. "delegated" postpones writing back changes in the container to the host in order to achieve higher filesystem throughput.

So, instead of ``-v `pwd`:/opt/nodemcu-firmware`` you would say ``-v `pwd`:/opt/nodemcu-firmware:delegated`` (note the flag at the end).

# Updating NodeMCU
The NodeMCU team hopes that you will want to regularly pull their latest updates into your cloned repository and build
a new firmware. There is more than one way to skin a cat and thus this chapter has unfortunately-but-intentionally to 
be brief.

## Starting over
The simplest process is to discard your local changes, update the firmware, and then manually reapply them. That may
be appropriate if all you changed are a handful of settings in the `.h` files.
```
git reset --hard origin/<name-of-the-branch-you-work-with>
git submodule update --recursive
```
Afterwards you would manually re-edit the files and run Docker again.

## Attempt to preserve your changes
Git is extremely flexible and powerful. What process you follow is very often just a matter of taste. In any case,
unless you are familiar with Git-fu the least you want to be dealing with is conflict resolution on the command line (
both you and NodeMCU updated the same file => potential conflict).

One way to _attempt_ to preserve your changes is using [`git stash`](https://www.atlassian.com/git/tutorials/saving-changes/git-stash). 
I say "attempt" because you still might end up with conflicts.

```
git stash
git pull
git submodule update --recursive
git stash pop
```

# Support
Ask a question on [StackOverflow](http://stackoverflow.com/) and assign the `nodemcu` and `docker` tags.

For bugs and improvement suggestions create an issue at [https://github.com/marcelstoer/docker-nodemcu-build/issues](https://github.com/marcelstoer/docker-nodemcu-build/issues).

# Credits
Thanks to [Paul Sokolovsky](http://pfalcon-oe.blogspot.com/) who created and maintains [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk).

A big "Thank You!" goes to [Gregor Hartmann](https://github.com/HHHartmann) who implemented LFS-support and removed the ill-designed `INTEGER_ONLY` / `FLOAT_ONLY` parameters for this image.

# Author
[https://frightanic.com](http://frightanic.com)
