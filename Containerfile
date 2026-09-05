FROM ubuntu:26.04 AS source

ADD --checksum=sha256:0c46bb6a88aa2782b10853a7b07cf3387ba99cbef2b966372cd2315b8571abea https://github.com/PCSX2/pcsx2/releases/download/v2.8.2/pcsx2-v2.8.2-linux-appimage-x64-Qt.AppImage /tmp/source

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
