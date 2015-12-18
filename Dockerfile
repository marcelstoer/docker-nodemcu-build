FROM ubuntu
MAINTAINER marcelstoer

RUN sudo apt-get update -y && sudo apt-get install -y git make python-serial srecord
RUN mkdir /opt/nodemcu-firmware
WORKDIR /opt/nodemcu-firmware

# Steps:
# - store the Git branch in 'BRANCH'
# - unpack esp-open-sdk.tar.gz in a directory that is NOT the bound mount directory (i.e. inside the Docker image)
# - remove all files in <firmware-dir>/bin
# - make a float build
# - make an integer build
CMD BRANCH="$(git rev-parse --abbrev-ref HEAD)" && \
    BUILD_DATE="$(date +%Y%m%d-%H%M)" && \
    cp tools/esp-open-sdk.tar.gz ../ && \
    cd ..  && \
    tar -zxvf esp-open-sdk.tar.gz  && \
    export PATH=$PATH:$PWD/esp-open-sdk/sdk:$PWD/esp-open-sdk/xtensa-lx106-elf/bin  && \
    cd nodemcu-firmware  && \
    make clean all  && \
    cd bin  && \
    srec_cat -output nodemcu_float_"${BRANCH}"_"${BUILD_DATE}".bin -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000 && \
    cd ../ && \
    make EXTRA_CCFLAGS="-DLUA_NUMBER_INTEGRAL" clean all && \
    cd bin/ && \
    srec_cat -output nodemcu_integer_"${BRANCH}"_"${BUILD_DATE}".bin -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000
