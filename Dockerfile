FROM ubuntu
MAINTAINER marcelstoer

RUN sudo apt-get update -y && sudo apt-get install -y git make python-serial srecord
RUN mkdir /opt/nodemcu-firmware
WORKDIR /opt/nodemcu-firmware

CMD BRANCH="$(git rev-parse --abbrev-ref HEAD)" && \
    cp tools/esp-open-sdk.tar.gz ../ && \
    cd ..  && \
    tar -zxvf esp-open-sdk.tar.gz  && \
    export PATH=$PATH:$PWD/esp-open-sdk/sdk:$PWD/esp-open-sdk/xtensa-lx106-elf/bin  && \
    cd nodemcu-firmware  && \
    rm -f bin/* && \
    make clean all  && \
    cd bin  && \
    srec_cat -output nodemcu_float_"${BRANCH}".bin -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000 && \
    cd ../ && \
    make EXTRA_CCFLAGS="-DLUA_NUMBER_INTEGRAL" clean all && \
    cd bin/ && \
    srec_cat -output nodemcu_integer_"${BRANCH}".bin -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000
