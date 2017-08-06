#!/usr/bin/env bash

set -e

# Config options you may pass via Docker like so 'docker run -e "<option>=<value>"':
# - IMAGE_NAME=<name>, define a static name for your .bin files
# - INTEGER_ONLY=1, if you want the integer firmware
# - FLOAT_ONLY=1, if you want the floating point firmware

# use the Git branch and the current time stamp to define image name if IMAGE_NAME not set
if [ -z "$IMAGE_NAME" ]; then
  BRANCH="$(git rev-parse --abbrev-ref HEAD | sed -r 's/[\/\\]+/_/g')"
  BUILD_DATE="$(date +%Y%m%d-%H%M)"
  IMAGE_NAME=${BRANCH}_${BUILD_DATE}
else
  true
fi

# unpack esp-open-sdk.tar.gz in a directory that is NOT the bound mount directory (i.e. inside the Docker image)
cp tools/esp-open-sdk.tar.* ../
cd ..
# support older build chains (before we re-packaged it)
if [ -f ./esp-open-sdk.tar.xz ]; then
  tar -Jxvf esp-open-sdk.tar.xz
else
  tar -zxvf esp-open-sdk.tar.gz
fi

export PATH=$PATH:$PWD/esp-open-sdk/sdk:$PWD/esp-open-sdk/xtensa-lx106-elf/bin
export CCACHE_DIR=/opt/nodemcu-firmware/.ccache
cd nodemcu-firmware

# make a float build if !only-integer
if [ -z "$INTEGER_ONLY" ]; then
  make WRAPCC=`which ccache` clean all
  cd bin
  srec_cat -output nodemcu_float_"${IMAGE_NAME}".bin -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000
  # copy and rename the mapfile to bin/
  cp ../app/mapfile nodemcu_float_"${IMAGE_NAME}".map
  cd ../
else
  true
fi

# make an integer build
if [ -z "$FLOAT_ONLY" ]; then
  make WRAPCC=`which ccache` EXTRA_CCFLAGS="-DLUA_NUMBER_INTEGRAL" clean all
  cd bin
  srec_cat -output nodemcu_integer_"${IMAGE_NAME}".bin -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000
  # copy and rename the mapfile to bin/
  cp ../app/mapfile nodemcu_integer_"${IMAGE_NAME}".map
else
  true
fi
