# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CURA_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=Cura \
    NO_GAMEPAD=true

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/cura-logo.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  add-apt-repository ppa:xtradeb/apps && \
  apt-get install --no-install-recommends -y \
    firefox && \
  echo "**** install cura from appimage ****" && \
  if [ -z ${CURA_VERSION+x} ]; then \
    CURA_VERSION=$(curl -sX GET "https://api.github.com/repos/Ultimaker/Cura/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  cd /tmp && \
  curl -o \
    /tmp/cura.app -L \
    "https://github.com/Ultimaker/Cura/releases/download/${CURA_VERSION}/UltiMaker-Cura-$(echo ${CURA_VERSION} | awk -F'-' '{print $1}')-linux-X64.AppImage" && \
  chmod +x /tmp/cura.app && \
  ./cura.app --appimage-extract && \
  mv squashfs-root /opt/cura && \
  sed -i 's/QT_QPA_PLATFORMTHEME=xdgdesktopportal/QT_QPA_PLATFORMTHEME=gtk3/' /opt/cura/AppRun.env && \
  sed -i 's|</applications>|  <application title="UltiMaker Cura" type="normal">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' /etc/xdg/openbox/rc.xml && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001
VOLUME /config
