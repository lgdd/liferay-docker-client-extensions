# Liferay Docker Client Extensions

Example to run Liferay and Client Extensions in a Docker Compose stack.

  - [Spring Boot](#spring-boot)
  - [Node JS](#node-js)

## Requirements

To test this repository, you need to run `docker compose build` first to build the client extensions' images and the Liferay (which ships the client extensions' configurations).

## Spring Boot

To make the [Spring Boot Sample](https://github.com/lgdd/liferay-client-extensions-samples/tree/main/liferay-sample-etc-spring-boot) work, you need to make the following list of changes.

1 - Add the information about Liferay by adding the following lines to the [`application-default.properties`](client-extensions/spring-boot/src/main/resources/application-default.properties#L17) file:

```properties
com.liferay.lxc.dxp.domains=liferay:8080
com.liferay.lxc.dxp.mainDomain=liferay:8080
com.liferay.lxc.dxp.server.protocol=http
```
Or by adding a folder (e.g. [`dxp-metadata`](client-extensions/spring-boot/dxp-metadata)) with a file per line containing its value and set the environment variable `LIFERAY_ROUTES_DXP` with the path to this folder (see [`Dockerfile`](client-extensions/spring-boot/Dockerfile#L24)):

```bash
spring-boot
    ├── dxp-metadata
    │   ├── com.liferay.lxc.dxp.domains
    │   ├── com.liferay.lxc.dxp.mainDomain
    │   └── com.liferay.lxc.dxp.server.protocol

# com.liferay.lxc.dxp.domains contains "liferay:8080"
# com.liferay.lxc.dxp.mainDomain contains "liferay:8080"
# com.liferay.lxc.dxp.server.protocol contains "http"
```
> `liferay` matches the name of the service in our [`docker-compose.yml`](docker-compose.yml) file.

2 - Update the service address in the [`client-extension.yaml`](client-extensions/spring-boot/client-extension.yaml#L9) file:
```diff
liferay-sample-etc-spring-boot-oauth-application-user-agent:
-   .serviceAddress: localhost:58081
+   .serviceAddress: springboot:58081
    .serviceScheme: http
```
> `springboot` matches the name of the service in our `docker-compose.yml` file.

3 - Update the `virtual.hosts.valid.hosts` property to accept the name of your Docker service (in our case, it's `liferay`):

Using the `portal-ext.properties`:
```diff
virtual.hosts.valid.hosts=\
+   liferay,\
    localhost,\
    127.0.0.1,\
    [::1],\
    [0:0:0:0:0:0:0:1]
```

Or using [environment variables](docker-compose.yml#L7):
```diff
services:
  liferay:
    image: liferay/dxp:2024.q1.4
+   environment:
+     LIFERAY_VIRTUAL_PERIOD_HOSTS_PERIOD_VALID_PERIOD_HOSTS: liferay,localhost,127.0.0.1,[::1],[0:0:0:0:0:0:0:1]
```

4 - Update the [`Dockerfile`](client-extensions/spring-boot/Dockerfile) for our Spring Boot application:
```Dockerfile
FROM azul/zulu-openjdk-alpine:11-latest as build
ARG CLIENT_EXTENSION_NAME=spring-boot

WORKDIR /workspace

COPY gradle gradle
COPY gradlew gradlew
COPY gradle.properties gradle.properties
COPY settings.gradle settings.gradle
COPY build.gradle build.gradle

RUN ./gradlew

COPY platform.bndrun platform.bndrun
COPY configs configs
COPY client-extensions/$CLIENT_EXTENSION_NAME client-extensions/$CLIENT_EXTENSION_NAME

RUN ./gradlew :client-extensions:$CLIENT_EXTENSION_NAME:build

FROM liferay/jar-runner:latest
ARG CLIENT_EXTENSION_NAME=spring-boot

COPY --from=build --chown=liferay:liferay /workspace/client-extensions/$CLIENT_EXTENSION_NAME/build/libs/*.jar /opt/liferay/jar-runner.jar
# COPY --from=build --chown=liferay:liferay /workspace/client-extensions/$CLIENT_EXTENSION_NAME/dxp-metadata /opt/liferay/dxp-metadata
# ENV LIFERAY_ROUTES_DXP=/opt/liferay/dxp-metadata
```
> This one is opinionated because I have a build step which is not required. You could copy the jar built locally in your Dockerfile. But I find it more consistent to build in the Dockerfile since you control the JDK used.

## Node JS

To make the [Node JS Sample](https://github.com/lgdd/liferay-client-extensions-samples/tree/main/liferay-sample-etc-node) work, you need to make the following list of changes.

1 - Add the information about Liferay by adding a folder (e.g. [`dxp-metadata`](client-extensions/node-js/dxp-metadata)) with a file per line containing its value:

```bash
node-js
    ├── dxp-metadata
    │   ├── com.liferay.lxc.dxp.domains
    │   ├── com.liferay.lxc.dxp.mainDomain
    │   └── com.liferay.lxc.dxp.server.protocol

# com.liferay.lxc.dxp.domains contains "liferay:8080"
# com.liferay.lxc.dxp.mainDomain contains "liferay:8080"
# com.liferay.lxc.dxp.server.protocol contains "http"
```

And and set the environment variable `LIFERAY_ROUTES_DXP` with the path to this folder (see [`Dockerfile`](client-extensions/node-js/Dockerfile#L5)):
```Dockerfile
FROM liferay/node-runner:latest

COPY --chown=liferay:liferay client-extensions/node-js /opt/liferay

ENV LIFERAY_ROUTES_DXP=/opt/liferay/dxp-metadata

RUN npm install
```

2 - Update the service address in the [`client-extension.yaml`](client-extensions/spring-boot/client-extension.yaml#L9) file:
```diff
liferay-sample-etc-node-oauth-application-user-agent:
-   .serviceAddress: localhost:3001
+   .serviceAddress: nodejs:3001
    .serviceScheme: http
```
> `nodejs` matches the name of the service in our `docker-compose.yml` file.

3 - Update the `virtual.hosts.valid.hosts` property to accept the name of your Docker service (in our case, it's `liferay`):

Using the `portal-ext.properties`:
```diff
virtual.hosts.valid.hosts=\
+   liferay,\
    localhost,\
    127.0.0.1,\
    [::1],\
    [0:0:0:0:0:0:0:1]
```

Or using [environment variables](docker-compose.yml#L7):
```diff
services:
  liferay:
    image: liferay/dxp:2024.q1.4
+   environment:
+     LIFERAY_VIRTUAL_PERIOD_HOSTS_PERIOD_VALID_PERIOD_HOSTS: liferay,localhost,127.0.0.1,[::1],[0:0:0:0:0:0:0:1]
```