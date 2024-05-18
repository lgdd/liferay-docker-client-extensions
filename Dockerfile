FROM azul/zulu-openjdk-alpine:11-latest as build
ARG TARGET_ENV=local

RUN apk add --no-cache dos2unix

WORKDIR /root/.liferay/workspace

RUN wget https://raw.githubusercontent.com/lgdd/liferay-product-info/main/releases.json

WORKDIR /workspace

COPY gradle gradle
COPY gradlew gradlew
COPY gradle.properties gradle.properties
COPY settings.gradle settings.gradle
COPY build.gradle build.gradle
COPY platform.bndrun platform.bndrun

RUN dos2unix gradlew
RUN ./gradlew

COPY configs configs
COPY client-extensions client-extensions

RUN ./gradlew deploy

FROM liferay/dxp:2024.q1.4
ARG TARGET_ENV=prod

COPY --from=build --chown=liferay:liferay /workspace/configs/$TARGET_ENV /mnt/liferay/files
COPY --from=build --chown=liferay:liferay /workspace/bundles/osgi/client-extensions /mnt/liferay/files/osgi/client-extensions

HEALTHCHECK --interval=15s --timeout=3s --retries=30 --start-period=30s \
  CMD curl --silent --fail 127.0.0.1:8080/c/portal/robots || exit 1