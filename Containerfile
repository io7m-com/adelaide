ARG version
ARG version_alpine
ARG version_temurin

FROM docker.io/library/alpine:$version_alpine
FROM docker.io/library/eclipse-temurin:$version_temurin

ENV PATH="/artemis/bin:/opt/java/openjdk/bin:/sbin:/bin:/usr/sbin:/usr/bin"

LABEL "org.opencontainers.image.authors"="Mark Raynsford"
LABEL "org.opencontainers.image.description"="A better ActiveMQ/Artemis OCI image."
LABEL "org.opencontainers.image.licenses"="ISC"
LABEL "org.opencontainers.image.source"="https://www.github.com/io7m-com/adelaide"
LABEL "org.opencontainers.image.title"="Adelaide"
LABEL "org.opencontainers.image.url"="https://www.github.com/io7m-com/adelaide"
LABEL "org.opencontainers.image.version"="$version"

RUN apk update
RUN apk add ca-certificates-bundle
RUN apk add curl

COPY artemis /artemis
COPY broker.sh /broker.sh
RUN chmod 755 /broker.sh
COPY broker-tls-reload.sh /broker-tls-reload.sh
RUN chmod 755 /broker-tls-reload.sh

RUN mkdir /data
RUN mkdir /data/etc
RUN mkdir /tls

VOLUME "/data"
VOLUME "/data/etc"
VOLUME "/tls"

ENTRYPOINT ["/broker.sh"]
