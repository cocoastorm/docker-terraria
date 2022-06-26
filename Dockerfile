FROM alpine:latest

ARG version="1436"
LABEL maintainer="khoa <khoa@cocoastorm.com>"

ADD https://terraria.org/api/download/pc-dedicated-server/terraria-server-${version}.zip /tmp/terraria.zip

RUN apk -U upgrade && \
  apk add --no-cache --virtual .build-deps unzip && \
  apk add --no-cache ca-certificates shadow su-exec tini && \
  apk add --no-cache mono --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
  useradd -d /opt/terraria -U terraria && \
  mkdir -p /tmp/terraria-server && \
  mkdir -p /opt/terraria && \
  chown terraria: /opt/terraria && \
  unzip /tmp/terraria.zip -d /tmp/terraria-server && \
  cp -r /tmp/terraria-server/${version}/Linux/* /opt/terraria && \
  rm -f /opt/terraria/System.dll && \
  cp /tmp/terraria-server/${version}/Windows/serverconfig.txt /opt/terraria/serverconfig-default.txt && \
  chmod a+x /opt/terraria/TerrariaServer && chmod a+x /opt/terraria/TerrariaServer.bin.x86_64 && \
  mkdir -p /opt/terraria/.local/share/Terraria && \
  echo "{}" > /opt/terraria/.local/share/Terraria/favorites.json && \
  apk del .build-deps && \
  rm -rf /tmp/*

RUN mkdir /config && mkdir /worlds && chown terraria: /config /worlds

COPY docker-entrypoint.sh /usr/local/bin/

EXPOSE 7777
VOLUME ["/config/", "worlds"]

WORKDIR /opt/terraria
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["-config", "/config/serverconfig.txt"]
