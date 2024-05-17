FROM azul/zulu-openjdk-alpine:11-latest as build
ARG CLIENT_EXTENSION_NAME=spring-boot

RUN apk add --no-cache dos2unix

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
COPY client-extensions/$CLIENT_EXTENSION_NAME client-extensions/$CLIENT_EXTENSION_NAME

RUN ./gradlew :client-extensions:$CLIENT_EXTENSION_NAME:build

FROM liferay/jar-runner:latest
ARG CLIENT_EXTENSION_NAME=spring-boot

COPY --from=build --chown=liferay:liferay /workspace/client-extensions/$CLIENT_EXTENSION_NAME/build/libs/*.jar /opt/liferay/jar-runner.jar
COPY --from=build --chown=liferay:liferay /workspace/client-extensions/$CLIENT_EXTENSION_NAME/dxp-metadata /opt/liferay/dxp-metadata
ENV LIFERAY_ROUTES_DXP=/opt/liferay/dxp-metadata