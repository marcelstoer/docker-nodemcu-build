#!/usr/bin/env bash

set -e

# Config options you may pass via Docker like so 'docker run -e "<option>=<value>"':
# - IMAGE_NAME=<name>, define a static name for your .bin files
# - INTEGER_ONLY=1, if you want the integer firmware
# - FLOAT_ONLY=1, if you want the floating point firmware

export BUILD_DATE COMMIT_ID BRANCH SSL
BUILD_DATE="$(date "+%Y-%m-%d %H:%M")"
COMMIT_ID="$(git rev-parse HEAD)"
BRANCH="$(git rev-parse --abbrev-ref HEAD | sed -r 's/[\/\\]+/_/g')"

# figure out whether SSL is enabled in user_config.h
if grep -Eq "^#define CLIENT_SSL_ENABLE" app/include/user_config.h; then
    SSL="true"
else
    SSL="false"
fi

# check whether the user made changes to the version file, if so then assume she wants to use a custom version rather
# than the one that would be set here -> we can't modify it
if git diff --quiet app/include/user_version.h; then
    CAN_MODIFY_VERSION=true
else
    CAN_MODIFY_VERSION=false
fi

# use the Git branch and the current time stamp to define image name if IMAGE_NAME not set
if [ -z "$IMAGE_NAME" ]; then
  IMAGE_NAME=${BRANCH}_"$(date "+%Y%m%d-%H%M")"
else
  true
fi

# unpack esp-open-sdk.tar.gz into a directory that is NOT the bound mount directory (i.e. inside the Docker image)
export HOME=/tmp/esp
rm -rf ${HOME}
mkdir ${HOME}

cp tools/esp-open-sdk.tar.* ${HOME}
cd ${HOME}
# support older build chains (before we re-packaged it)
if [ -f ./esp-open-sdk.tar.xz ]; then
  tar -Jxvf esp-open-sdk.tar.xz
else
  tar -zxvf esp-open-sdk.tar.gz
fi

export PATH=$PATH:$PWD/esp-open-sdk/sdk:$PWD/esp-open-sdk/xtensa-lx106-elf/bin
export CCACHE_DIR=/opt/nodemcu-firmware/.ccache

cd /opt/nodemcu-firmware

# modify user_version.h to provide more info in NodeMCU welcome message, doing this by passing
# EXTRA_CCFLAGS="-DBUILD_DATE=... AND -DNODE_VERSION=..." to make turned into an escaping/expanding nightmare for which
# I never found a good solution
if [ "$CAN_MODIFY_VERSION" = true ]; then
  sed -i '/#define NODE_VERSION[[:space:]]/ s/$/ " built with Docker provided by frightanic.com\\n\\tbranch: '"$BRANCH"'\\n\\tcommit: '"$COMMIT_ID"'\\n\\tSSL: '"$SSL"'\\n"/g' app/include/user_version.h
  sed -i 's/"unspecified"/"created on '"$BUILD_DATE"'\\n"/g' app/include/user_version.h
fi

# make a float build if !only-integer
if [ -z "$INTEGER_ONLY" ]; then
  make WRAPCC="$(which ccache)" clean all
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
  make WRAPCC="$(which ccache)" EXTRA_CCFLAGS="-DLUA_NUMBER_INTEGRAL" clean all
  cd bin
  srec_cat -output nodemcu_integer_"${IMAGE_NAME}".bin -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000
  # copy and rename the mapfile to bin/
  cp ../app/mapfile nodemcu_integer_"${IMAGE_NAME}".map
  cd ../
else
  true
fi

# revert the changes made to the version params
if [ "$CAN_MODIFY_VERSION" = true ]; then
  git checkout app/include/user_version.h
fi
