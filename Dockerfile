FROM debian:jessie

MAINTAINER Xander Hendriks <xander.hendriks@nx-solutions.com>

ENV DEBIAN_FRONTEND noninteractive

# Microchip tools require i386 compatability libs
# Extra tools:
# - curl: Downloading installers
# - unzip: Unzipping downloaded files
# - python3: Building the projects from CI tools
#   - python3-pip: For using requirements.txt
#   - python3-dev: Required for the installation of some packages
# - gcc: Compiler required for some python packages
RUN dpkg --add-architecture i386 \
    && apt-get update -yq \
    && apt-get install -yq --no-install-recommends curl unzip python3 python3-pip python3-dev gcc \
       libc6:i386 libx11-6:i386 libxext6:i386 libstdc++6:i386 libexpat1:i386 \
       libxext6 libxrender1 libxtst6 libgtk2.0-0 libxslt1.1


ENV XC8_VERSION 2.20

# Download and install XC8 compiler
RUN curl -fSL -A "Mozilla/4.0" -o /tmp/xc8.run "http://ww1.microchip.com/downloads/en/DeviceDoc/xc8-v${XC8_VERSION}-full-install-linux-installer.run" \
    && chmod a+x /tmp/xc8.run \
    && /tmp/xc8.run --mode unattended --unattendedmodeui none \
       --netservername localhost --LicenseType FreeMode \
    && rm /tmp/xc8.run
ENV PATH /opt/microchip/xc8/v${XC8_VERSION}/bin:$PATH


ENV XC32_VERSION 1.42

# Download and install XC32 compiler
RUN curl -fSL -A "Mozilla/4.0" -o /tmp/xc32.run "http://ww1.microchip.com/downloads/en/DeviceDoc/xc32-v${XC32_VERSION}-full-install-linux-installer.run" \
    && chmod a+x /tmp/xc32.run \
    && /tmp/xc32.run --mode unattended --unattendedmodeui none \
        --netservername localhost --LicenseType FreeMode \
    && rm /tmp/xc32.run
ENV PATH /opt/microchip/xc32/v${XC32_VERSION}/bin:$PATH


ENV MPLABX_VERSION 5.40

# Download and install MPLAB X IDE
# Use url: http://www.microchip.com/mplabx-ide-linux-installer to get the latest version
RUN curl -fSL -A "Mozilla/4.0" -o /tmp/mplabx-installer.tar "http://ww1.microchip.com/downloads/en/DeviceDoc/MPLABX-v${MPLABX_VERSION}-linux-installer.tar" \
    && tar xf /tmp/mplabx-installer.tar && rm /tmp/mplabx-installer.tar \
    && USER=root ./MPLABX-v${MPLABX_VERSION}-linux-installer.sh --nox11 \
        -- --unattendedmodeui none --mode unattended \
    && rm ./MPLABX-v${MPLABX_VERSION}-linux-installer.sh


ENV PIC32MX_DFP_PACK_VERSION 1.3.231

# Download and install the PIC32MX Device Family Pack (DFP)
RUN curl --insecure -fSL -A "Mozilla/4.0" -o /tmp/pic32mx_dfp_pack.atpack "http://packs.download.microchip.com/Microchip.PIC32MX_DFP.${PIC32MX_DFP_PACK_VERSION}.atpack" \
    && mkdir -p /root/.mchp_packs/Microchip/PIC32MX_DFP/${PIC32MX_DFP_PACK_VERSION} \
    && unzip /tmp/pic32mx_dfp_pack.atpack -d /root/.mchp_packs/Microchip/PIC32MX_DFP/${PIC32MX_DFP_PACK_VERSION} \
    && rm /tmp/pic32mx_dfp_pack.atpack


# Download and install the PIC32 Legacy Peripheral Libraries
RUN curl -fSL -A "Mozilla/4.0" -o /tmp/pic32_legacy_peripheral_library.tar "http://ww1.microchip.com/downloads/en//softwarelibrary/pic32%20peripheral%20library/pic32%20legacy%20peripheral%20libraries%20linux%20(2).tar" \
    && tar -xf /tmp/pic32_legacy_peripheral_library.tar --directory=tmp --xform="s/.*/pic32_legacy_peripheral_library.run/" \
    && chmod a+x /tmp/pic32_legacy_peripheral_library.run \
    && /tmp/pic32_legacy_peripheral_library.run --mode unattended --unattendedmodeui none \
        --prefix /opt/microchip/xc32/v${XC32_VERSION} \
    && rm /tmp/pic32_legacy_peripheral_library.tar /tmp/pic32_legacy_peripheral_library.run


# Required? for starting the MPLAB GUI
VOLUME ["/tmp/.X11-unix"]
