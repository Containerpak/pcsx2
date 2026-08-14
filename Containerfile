FROM ubuntu:26.04 AS source

ADD --checksum=sha256:8ce7de8613c17b00b01028a512dd1b81998b6626ebbe93a067e0eb20aeedd5bf https://github.com/PCSX2/pcsx2/releases/download/v2.6.3/pcsx2-v2.6.3-linux-appimage-x64-Qt.AppImage /tmp/source

RUN chmod 0755 /tmp/source && \
    cd /tmp && \
    ./source --appimage-extract >/dev/null && \
    mv /tmp/squashfs-root /out

FROM ghcr.io/containerpak/gtk3:main

COPY --from=source /out /opt/pcsx2

RUN apt-get update && \
    apt-get install -y --no-install-recommends libasound2t64 libpulse0 && \
    mkdir -p /usr/share/applications && \
    printf '#!/bin/sh\nexec /opt/pcsx2/AppRun "$@"\n' > /usr/bin/pcsx2 && \
    chmod 0755 /usr/bin/pcsx2 && \
    printf '[Desktop Entry]\nName=PCSX2\nExec=pcsx2 %%f\nIcon=net.pcsx2.PCSX2\nType=Application\nCategories=Game;Emulator;\n' > /usr/share/applications/net.pcsx2.PCSX2.desktop && \
    cpak-clean-junk
