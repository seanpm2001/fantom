# ================================
# Bootstrap image
# ================================
# This image builds the local Fantom installation using the Fantom Bootstrap process.
#
# It mirrors the Bootstrap.fan script, but does not use it (since we want to use the 
# local fantom, not one pulled via git).

FROM openjdk:8-jdk as bootstrap

ARG FAN_DL_URL=https://github.com/fantom-lang/fantom/releases/download
# SWT 4.16 was the last one with JDK 8 support
ARG SWT_DL_URL=https://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.16-202006040540/swt-4.16-gtk-linux-x86_64.zip

# These define the `rel` Fantom version.
ARG REL_VERSION=fantom-1.0.77
ARG REL_TAG=v1.0.77

WORKDIR /work

RUN set -e; \
    FAN_BIN_URL="$FAN_DL_URL/$REL_TAG/$REL_VERSION.zip" \
    # Install curl
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -q update && apt-get -q install -y curl && rm -rf /var/lib/apt/lists/* \
    # Download Fantom
    && curl -fsSL "$FAN_BIN_URL" -o fantom.zip \
    && unzip fantom.zip -d fantom \
    && mv fantom/$REL_VERSION rel \
    && chmod +x rel/bin/* \
    && rm -rf fantom && rm -f fantom.zip \
    # Download linux-x86_64 SWT
    && curl -fsSL "$SWT_DL_URL" -o swt.zip \
    && unzip swt.zip -d swt \
    && mv swt/swt.jar ./ \
    && rm -rf swt && rm -f swt.zip

COPY . ./fan/

# Copy SWT into installations
RUN mkdir rel/lib/java/ext/linux-x86_64 \
    && cp swt.jar rel/lib/java/ext/linux-x86_64/ \
    && mkdir fan/lib/java/ext/linux-x86_64 \
    && cp swt.jar fan/lib/java/ext/linux-x86_64/ \
    && rm swt.jar

# Populate config.props with jdkHome (to use jdk, not jre) and devHome
RUN echo -e "\n\njdkHome=/usr/local/openjdk-8/\ndevHome=/work/fan/\n" >> rel/etc/build/config.props \
    && echo -e "\n\njdkHome=/usr/local/openjdk-8/" >> fan/etc/build/config.props

RUN rel/bin/fan fan/src/buildall.fan superclean \
    && rel/bin/fan fan/src/buildboot.fan compile \
    && fan/bin/fan fan/src/buildpods.fan compile

# The /work/fan directory now contains a compiled version of the local Fantom

# ================================
# Run image
# ================================
# This simply copies the new Fantom into a fresh container and sets up the path.

FROM openjdk:8-jdk

COPY --from=bootstrap /work/fan/ /opt/fan/

ENV PATH $PATH:/opt/fan/bin

# Return Fantom's version
CMD ["fan","-version"]