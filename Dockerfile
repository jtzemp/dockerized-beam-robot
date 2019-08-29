FROM ubuntu:16.04

COPY beam-2.22.1-Linux.deb /usr/src

RUN apt-get update && \
    apt-get install --assume-yes \
    xdg-utils \
    libusb-1.0-0 \
    icewm \
    libxcb-icccm4 libxcb-image0 libunwind8 libpulse0

RUN dpkg -i /usr/src/beam-2.22.1-Linux.deb

ENTRYPOINT /usr/bin/beam
