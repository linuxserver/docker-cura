FROM ghcr.io/linuxserver/baseimage-rdesktop-web:arch

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CURA_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
  echo "**** install cura ****" && \
  if [ -z ${CURA_VERSION+x} ]; then \
    CURA_VERSION=$(curl -sX GET "https://api.github.com/repos/Ultimaker/Cura/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  mkdir -p /app/cura/ && \
  curl -o \
    /app/cura/cura -L \
    "https://github.com/Ultimaker/Cura/releases/download/${CURA_VERSION}/Ultimaker-Cura-${CURA_VERSION}-linux-modern.AppImage" && \
  chmod +x /app/cura/cura && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
