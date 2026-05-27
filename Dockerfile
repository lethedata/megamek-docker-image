FROM alpine AS builder

ARG MM_VERSION
ENV MM_VERSION=${MM_VERSION}
ARG SENTRY_ENABLED
ENV SENTRY_ENABLED=${SENTRY_ENABLED}

WORKDIR /app

ADD  "https://github.com/MegaMek/megamek/releases/download/v${MM_VERSION}/megamek-${MM_VERSION}.tar.gz" /tmp/megamek.tar.gz
RUN tar -zxvf /tmp/megamek.tar.gz && mv MegaMek-${MM_VERSION} megamek && \
  mv megamek/docs/mm-revision.txt /app/mm-revision.txt && \
  rm -rf megamek/data/fonts && \
  rm -rf megamek/data/forcegenerator && \
  rm -rf megamek/data/images && \
  rm -rf megamek/data/names && \
  rm -rf megamek/data/rat && \
  rm -rf megamek/data/scenarios && \
  rm -rf megamek/data/sounds && \
  rm -rf megamek/docs && \
  mkdir megamek/docs && \
  mv /app/mm-revision.txt megamek/docs/mm-revision.txt && \
  rm -rf megamek/*.exe && \
  rm -rf megamek/*.sh && \
  rm megamek/sentry.properties && \
  echo "enabled=${SENTRY_ENABLED}" > megamek/sentry.properties

FROM eclipse-temurin:21-noble

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
  && apt-get -q update \
  && apt-get -q full-upgrade -y \
  && apt-get clean && \
  useradd --user-group --create-home --system --skel /dev/null --home-dir /app megamek

WORKDIR /app
EXPOSE 2346
USER megamek

COPY --from=builder --chown=megamek:megamek /app/megamek/ /app/

ENTRYPOINT ["java", "-jar", "MegaMek.jar"]
CMD ["-dedicated", "-port", "2346"]
