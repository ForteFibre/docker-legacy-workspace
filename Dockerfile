FROM ubuntu:focal AS base
RUN sed -i.bak -r 's!(deb|deb-src) \S+!\1 mirror://mirrors.ubuntu.com/mirrors.txt!' /etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates git make \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y gcc-arm-none-eabi

FROM base AS stlink-builder
WORKDIR /tmp
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends checkinstall cmake build-essential libusb-1.0-0-dev \
    && git clone https://github.com/stlink-org/stlink.git \
    && cd ./stlink \
    && make release \
    && checkinstall --install=no --default --nodoc

FROM base AS stm32plus-builder
WORKDIR /tmp
COPY stm32plus_stl.patch stm32plus_flags.patch /tmp/
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends scons \
    && git clone https://github.com/andysworkshop/stm32plus.git \
    && cd ./stm32plus \
    && git apply --whitespace=fix /tmp/stm32plus_stl.patch /tmp/stm32plus_flags.patch \
    && export JOBS=$(grep -c processor /proc/cpuinfo) \
    && scons mode=small mcu=f1md hse=8000000 -j$JOBS examples=no \
    && scons mode=small mcu=f1hd hse=8000000 -j$JOBS examples=no \
    && scons mode=small mcu=f1md hse=12000000 -j$JOBS examples=no \
    && scons mode=small mcu=f1hd hse=12000000 -j$JOBS examples=no \
    && scons mode=small mcu=f4 hse=8000000 -j$JOBS float=hard examples=no \
    && scons mode=small mcu=f4 hse=12000000 -j$JOBS float=hard examples=no \
    && scons mode=small mcu=f4 hse=25000000 -j$JOBS float=hard examples=no \
    && scons mode=small mcu=f429 hse=8000000 -j$JOBS float=hard examples=no

FROM base AS devcontainer
ENV STM32PLUS_DIR_BASENAME=/workspaces
ENV STM32PLUS_DIR=$STM32PLUS_DIR_BASENAME/stm32plus

WORKDIR /tmp
COPY --from=stlink-builder /tmp/stlink/stlink*.deb stlink.deb
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gdb-multiarch libusb-1.0-0 ./stlink.deb \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

COPY --from=stm32plus-builder /tmp/stm32plus/lib $STM32PLUS_DIR
WORKDIR $STM32PLUS_DIR/build
RUN ln -s small-f1hd-8000000e small-f1hd-8000000 \
    && ln -s small-f1md-8000000e small-f1md-8000000 \
    && ln -s small-f1hd-12000000e small-f1hd-12000000 \
    && ln -s small-f1md-12000000e small-f1md-12000000 \
    && ln -s small-f4-8000000e-hard small-f4-8000000-hard \
    && ln -s small-f4-12000000e-hard small-f4-12000000-hard \
    && ln -s small-f4-25000000e-hard small-f4-25000000-hard \
    && ln -s small-f429-8000000e-hard small-f429-8000000-hard \
    && ln -s libstm32plus-small-f1hd-8000000e.a small-f1hd-8000000/libstm32plus-small-f1hd-8000000.a \
    && ln -s libstm32plus-small-f1md-8000000e.a small-f1md-8000000/libstm32plus-small-f1md-8000000.a \
    && ln -s libstm32plus-small-f1hd-12000000e.a small-f1hd-12000000/libstm32plus-small-f1hd-12000000.a \
    && ln -s libstm32plus-small-f1md-12000000e.a small-f1md-12000000/libstm32plus-small-f1md-12000000.a \
    && ln -s libstm32plus-small-f4-8000000e-hard.a small-f4-8000000-hard/libstm32plus-small-f4-8000000-hard.a \
    && ln -s libstm32plus-small-f4-12000000e-hard.a small-f4-12000000-hard/libstm32plus-small-f4-12000000-hard.a \
    && ln -s libstm32plus-small-f4-25000000e-hard.a small-f4-25000000-hard/libstm32plus-small-f4-25000000-hard.a \
    && ln -s libstm32plus-small-f429-8000000e-hard.a small-f429-8000000-hard/libstm32plus-small-f429-8000000-hard.a

WORKDIR /root
